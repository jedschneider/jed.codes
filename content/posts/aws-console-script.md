---
title: "Into the AWS Console with the Federation Endpoint"
date: 2026-07-14T20:15:11-07:00
draft: false
slug: "aws-console-federation-endpoint"
description: "Use AWS's federation endpoint to trade SSO credentials for a browser sign-in URL and jump straight into the console"
tags: [aws, infrastructure]
toc: true
images: ["/images/aws-console-federation-endpoint.png"]
---

![A steampunk wizard at a brass keyboard in a candlelit study. One screen is a terminal reading "$ bin/console lambda" over a glowing blue portal; a floating crystalline frame beside it shows an ornate key sliding into a padlock with the caption "Authenticated: Federation Token Accepted", topped by a storm cloud shooting lightning. A clockwork owl and potion bottles sit on the desk.](/images/aws-console-federation-endpoint.png)

I recently shared how I [set up AWS SSO to manage session access]({{< ref "setting-up-sso-for-your-personal-aws-account" >}}) for development. SSO gives me short-lived credentials on the command line, but there's still a gap: when I want to poke at something in the *web* console, I'm back to hunting through the AWS sign-in page and picking the right account and role by hand.

AWS's [federation endpoint](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html) trades temporary credentials for a browser sign-in URL, which is exactly what my SSO session already vends. The script I install in `bin/console` bridges the two. It reuses the session I have and drops me into the console without re-authenticating or clicking through an account picker.

```console
$ bin/console            # console home
$ bin/console lambda     # straight to the Lambda functions list
$ bin/console https://...  # any full console URL
```

## Configuration and shortcuts

The top of the script holds the two things that change per project, the profile and region, plus a lookup table of destinations I hit often.

```ruby
PROFILE = "my-profile"
REGION  = "us-west-2"

# extend as necessary, you see the pattern
SHORTCUTS = {
  "home"   => "https://#{REGION}.console.aws.amazon.com/console/home?region=#{REGION}",
  "lambda" => "https://#{REGION}.console.aws.amazon.com/lambda/home?region=#{REGION}#/functions"
}.freeze
```

Every console page is just a URL, so a shortcut is nothing more than a memorable name for one. Add whatever you find yourself navigating to: an S3 bucket, a CloudWatch log group, a DynamoDB table. The pattern is always `https://{region}.console.aws.amazon.com/{service}/home?region={region}#/...`.

## Resolving the destination

The first argument decides where you land. A full URL passes through untouched, a known shortcut name is expanded, and anything else fails loudly rather than silently opening the wrong place.

```ruby
def destination(arg)
  return arg if arg.start_with?("http")
  return SHORTCUTS[arg] if SHORTCUTS.key?(arg)

  abort "unknown target #{arg.inspect}; choose one of: #{SHORTCUTS.keys.join(', ')} or a full URL"
end
```

With no argument at all, `main` defaults to the `home` shortcut, so a bare `bin/console` still does something useful.

## Exchanging credentials for a sign-in token

The federation flow is the heart of the story here. With SSO, there is no console password; SSO hands me *temporary credentials*. To turn those into a signed-in browser session, AWS gives us the federation flow.

First, pull the current session's credentials out of the profile. The `export-credentials` command resolves whatever the SSO session currently vends into a plain access key, secret, and token:

```ruby
creds = JSON.parse(`aws --profile #{PROFILE} configure export-credentials --format process`)
```

Then repackage those three values into the `Session` JSON the federation endpoint expects, and ask it for a sign-in token:

```ruby
session = JSON.generate(
  sessionId:    creds["AccessKeyId"],
  sessionKey:   creds["SecretAccessKey"],
  sessionToken: creds["SessionToken"]
)

token_url = URI("https://signin.aws.amazon.com/federation?" +
  URI.encode_www_form(Action: "getSigninToken", Session: session))
token = JSON.parse(Net::HTTP.get(token_url))["SigninToken"]
```

`URI.encode_www_form` handles the escaping of that `Session` blob. The `SigninToken` that comes back is a short-lived credential the browser can redeem, the console equivalent of the CLI credentials I started with.

## Building the login URL and opening it

The last step wraps the sign-in token and the destination into a single `login` URL. Opening it redeems the token and redirects the browser to wherever `Destination` points.

```ruby
url = "https://signin.aws.amazon.com/federation?" +
  URI.encode_www_form(Action: "login", Issuer: "", Destination: dest, SigninToken: token)

open_browser(url)
puts "Opening console: #{dest}"
```

Ruby has no standard-library equivalent of Python's `webbrowser`, so `open_browser` picks the right launcher for the host OS:

```ruby
def open_browser(url)
  cmd = case RbConfig::CONFIG["host_os"]
        when /darwin/ then "open"
        when /mswin|mingw/ then "start"
        else "xdg-open"
        end
  system(cmd, url)
end
```

The console opens in your default browser, the session you're already logged into. Because the token derives from the SSO credentials, it inherits exactly the permissions of that role and expires when the session does.

## The whole thing

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

# Open the AWS console using the current SSO session.
#
# Exchanges the profile's exported credentials for a federation sign-in token
# and opens the browser at a destination. Pass a shortcut name or a full URL:
#
#   bin/console                # console home (us-west-2)
#   bin/console lambda         # the Lambda functions list

require "json"
require "net/http"
require "uri"

PROFILE = "my-profile"
REGION  = "us-west-2"

# extend as necessary, you see the pattern
SHORTCUTS = {
  "home"   => "https://#{REGION}.console.aws.amazon.com/console/home?region=#{REGION}",
  "lambda" => "https://#{REGION}.console.aws.amazon.com/lambda/home?region=#{REGION}#/functions"
}.freeze

def destination(arg)
  return arg if arg.start_with?("http")
  return SHORTCUTS[arg] if SHORTCUTS.key?(arg)

  abort "unknown target #{arg.inspect}; choose one of: #{SHORTCUTS.keys.join(', ')} or a full URL"
end

def open_browser(url)
  cmd = case RbConfig::CONFIG["host_os"]
        when /darwin/ then "open"
        when /mswin|mingw/ then "start"
        else "xdg-open"
        end
  system(cmd, url)
end

def main
  dest = ARGV[0] ? destination(ARGV[0]) : SHORTCUTS["home"]

  creds = JSON.parse(`aws --profile #{PROFILE} configure export-credentials --format process`)

  session = JSON.generate(
    sessionId:    creds["AccessKeyId"],
    sessionKey:   creds["SecretAccessKey"],
    sessionToken: creds["SessionToken"]
  )

  token_url = URI("https://signin.aws.amazon.com/federation?" +
    URI.encode_www_form(Action: "getSigninToken", Session: session))
  token = JSON.parse(Net::HTTP.get(token_url))["SigninToken"]

  url = "https://signin.aws.amazon.com/federation?" +
    URI.encode_www_form(Action: "login", Issuer: "", Destination: dest, SigninToken: token)

  open_browser(url)
  puts "Opening console: #{dest}"
end

main if $PROGRAM_NAME == __FILE__
```

Drop it in `bin/console`, make it executable, and one command later you're in the console, signed in as the role you're already using on the command line.

## The Python version

The same flow translates directly to Python, with no third-party packages either way.

```python
#!/usr/bin/env python3
"""Open the AWS console using the current SSO session.

Exchanges the profile's exported credentials for a federation sign-in token and
opens the browser at a destination. Pass a shortcut name or a full URL:

  bin/console                # console home (us-west-2)
  bin/console lambda         # the Lambda functions list
"""
import json
import subprocess
import sys
import urllib.parse
import urllib.request
import webbrowser

PROFILE = "my-profile"
REGION = "us-west-2"

# extend as necessary, you see the pattern
SHORTCUTS = {
    "home": f"https://{REGION}.console.aws.amazon.com/console/home?region={REGION}",
    "lambda": f"https://{REGION}.console.aws.amazon.com/lambda/home?region={REGION}#/functions",
}


def destination(arg: str) -> str:
    if arg.startswith("http"):
        return arg
    if arg in SHORTCUTS:
        return SHORTCUTS[arg]
    sys.exit(f"unknown target {arg!r}; choose one of: {', '.join(SHORTCUTS)} or a full URL")


def main() -> None:
    dest = destination(sys.argv[1]) if len(sys.argv) > 1 else SHORTCUTS["home"]

    creds = json.loads(subprocess.check_output([
        "aws", "--profile", PROFILE, "configure", "export-credentials", "--format", "process",
    ]))

    session = json.dumps({
        "sessionId": creds["AccessKeyId"],
        "sessionKey": creds["SecretAccessKey"],
        "sessionToken": creds["SessionToken"],
    })

    token_url = (
        "https://signin.aws.amazon.com/federation"
        "?Action=getSigninToken&Session=" + urllib.parse.quote(session)
    )
    token = json.loads(urllib.request.urlopen(token_url).read())["SigninToken"]

    url = (
        "https://signin.aws.amazon.com/federation"
        f"?Action=login&Issuer=&Destination={urllib.parse.quote(dest)}&SigninToken={token}"
    )
    webbrowser.open(url)
    print(f"Opening console: {dest}")


if __name__ == "__main__":
    main()
```
