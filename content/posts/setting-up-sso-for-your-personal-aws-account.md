---
title: "Setting Up SSO for Your Personal AWS Account"
date: 2026-07-04T11:00:23-07:00
draft: false
tags: [aws, infrastructure]
toc: true
---

I do a fair bit of my personal work in AWS using serverless services. I love deferring long-running services in favor of pay-for-what-you-use pricing; it makes a ton of sense to me, and many of my applications cost less than $1/mo. A gotcha I hear from folks: managing multiple projects under a single AWS account gets challenging, both from a "total cost of ownership" standpoint and when you want to constrain access to just one project. Having a **Single Sign On (SSO) AWS login** with multiple profiles is a stepping stone to a simpler AWS experience. 

Most people don't know it's built into AWS, so you pay nothing extra for the convenience. 

In this post I'll walk you through enabling AWS Organizations for your personal AWS account and configuring your local machine to log in to the specific sub-account where a project lives. I keep a 1:1 relationship between a source repo and an AWS account.

The end goal: type `aws sso login --profile <your-profile>` (I use `ogg` below) and be authenticated into the specific project's account, using a SSO flow I only do once a day.

## Setting up AWS Organizations

This is the one-time bootstrap, done from your existing "root" AWS account (the one that becomes the *management account*):

1. Open **AWS Organizations** and create an organization (choose *all features*, not just consolidated billing; you need all features for the SSO piece).
2. Enable **IAM Identity Center** (this is the service formerly called AWS SSO). This is the part that gives you the single login and costs nothing extra. When you enable it you get a **start URL** that looks like `https://d-xxxxxxxxxx.awsapps.com/start`.
3. Create (or confirm) a **user** in the Identity Center identity store. That user (say `you@example.com`) is the identity you'll actually log in as.
4. Create a **permission set**: a reusable access template (policies + session length), defined once at the org level, *not* tied to any single account. In this article mine is called `TerraformAdmin`.

Now for each project, **add an account** to the org (Organizations → Add an AWS account → Create). Each new account gets its own 12-digit id and its own root email. I keep a 1:1 between a source repo and an account. Provisioning isn't instant; it takes anywhere from a few minutes to about an hour, and AWS emails your organization's root/admin address when the account is ready.

<aside data-label="Tip">
    <p>Creating the account is <em>not</em> enough to log into it. That's the gotcha I cover at the very bottom.</p>
</aside>

## Setting up your local aws config

Once Identity Center is enabled you configure `~/.aws/config`. There are two kinds of blocks that matter.

First, an **`[sso-session]`** block. This represents the SSO portal itself, and you only need **one per organization**, since every account under the org shares it:

```ini
[sso-session jed.codes]
sso_start_url = https://d-xxxxxxxxxx.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access
```

Then, a **`[profile]`** block per account. Each one references that shared session and pins down which account + permission set you want:

```ini
[profile moria]
sso_session = jed.codes          # the shared portal, reused
sso_account_id = 111111111111    # this account's 12-digit id
sso_role_name = TerraformAdmin   # the permission set assigned to me here
region = us-east-1
```

Here's the mental model that makes the rest click: **`sso-session` maps to a login portal, `profile` maps to an account.** Adding a new project account almost never means a new session; it means one more `[profile]` block pointing the *same* session at a different `sso_account_id`. That's why I only authenticate once and then hop between accounts.

```text
              one login portal  (sso-session: jed.codes)
            https://d-xxxxxxxxxx.awsapps.com/start
                            |
         one `aws sso login` authenticates all of it
                            |
      +---------------------+---------------------+
      |                     |                     |
[profile moria]       [profile ogg]        [profile ...]
 account 111...        account 222...        account ...
 role Terraform        role Terraform        role ...
```

## Defining aliases

Here's a small thing that trips people up: the name in `[profile ogg]` is a **local alias**. It has nothing to do with what the account is named in AWS.

I created an account in the org named `mail-manager`, but the account name isn't what I want to type. I alias profiles to match how I think about the project. So my profile is just:

```ini
[profile ogg]
sso_session = jed.codes
sso_account_id = 222222222222    # this is "mail-manager" in the console
sso_role_name = TerraformAdmin
region = us-east-1
```

Nothing in that block references the string `mail-manager`, only the numeric id. The alias is free; name your profiles whatever your fingers want to type. Then:

```bash
aws sso login --profile ogg
aws sts get-caller-identity --profile ogg
```

```json
{
  "Account": "222222222222",
  "Arn": "arn:aws:sts::222222222222:assumed-role/AWSReservedSSO_TerraformAdmin_<hash>/you@example.com"
}
```

That `AWSReservedSSO_TerraformAdmin_<hash>` role matters; the gotcha section explains why it exists.

<aside data-label="Tip">
    <p>If you setup your <code>AGENTS.md</code> file, or hooks, with the profile name, the agent will actively wrap your aws commands with the correct profile, giving you scoping for your agent as well.</p>
</aside>

## Managing multiple SSO providers (accounts you don't manage)

The setup above is for *your* org. But you probably also have work accounts you don't control. Those live behind a **different SSO portal**, so they get their own `[sso-session]` block with a different start URL, and their own separate `aws sso login`:

```ini
[profile work-dev]
sso_session = work
sso_account_id = 333333333333
sso_role_name = PowerUser
region = us-east-2

[sso-session work]
sso_start_url = https://d-xxxxxxxxxx.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access
```

The takeaway is the same rule from before, stated in reverse: **one `[sso-session]` per portal.** Same org = reuse the session. Different org/employer = new session, new login. You can happily have several sessions side by side and switch between them per-profile.

## Caveats / security considerations / gotchas

**A new account is invisible until you assign yourself to it.** This is the step I forget every single time. You create the account in Organizations, go to configure your profile, and the account doesn't show up in `aws sso list-accounts`. It exists (`aws organizations list-accounts` proves it), but you have no access to it yet.

The fix is to create an **account assignment**: a three-way link between a permission set, the account, and your user. In the console: *IAM Identity Center → AWS accounts → pick the account → Assign users/groups → pick your user → pick the permission set.* Or from the CLI, run against your management account:

```bash
aws sso-admin create-account-assignment \
  --instance-arn      "arn:aws:sso:::instance/ssoins-xxxxxxxxxxxx" \
  --target-id         222222222222 \
  --target-type       AWS_ACCOUNT \
  --permission-set-arn "arn:aws:sso:::permissionSet/ssoins-xxxxxxxxxxxx/ps-xxxxxxxx" \
  --principal-type    USER \
  --principal-id      "<your-identity-store-user-id>"
```

When that runs, Identity Center **provisions an IAM role** into the target account named `AWSReservedSSO_<PermissionSet>_<hash>`. That's the role you saw in the `get-caller-identity` output earlier. The same permission set assigned into five accounts gives you five of those roles, which is why `sso_role_name = TerraformAdmin` works everywhere. After the assignment lands, run `aws sso login` again and the account shows up.

A few smaller ones:

- Tokens expire. A login gets you a session token good for a bounded window (often ~8h). When it lapses you'll see `Token has expired and refresh failed`, so log in again. One login covers every profile on that session.
- Account ids aren't secret, but think before publishing. They're not credentials, but I still lean toward redacting them in public writeups out of habit. (The ids in this post are placeholders.)
- `TerraformAdmin` is convenient but broad. Where you don't need that much access, define a narrower permission set and assign that instead (details below).

### Restricting access with a narrower permission set

You never create these roles in the sub-account yourself. A permission set is created once, centrally, in IAM Identity Center, which lives in your management account. When you assign it to an account, Identity Center auto-provisions the matching `AWSReservedSSO_*` role into that sub-account for you. So a restricted setup is just a second permission set with a tighter policy, assigned to the same account.

Here's the whole thing for a read-only view of the `ogg` (mail-manager) account, ending in `aws sso login --profile ogg-read-only`.

First, create the permission set and attach a policy. This runs against your management account:

```bash
# create the template with a short session
aws sso-admin create-permission-set \
  --instance-arn "arn:aws:sso:::instance/ssoins-xxxxxxxxxxxx" \
  --name "ReadOnly" --session-duration "PT2H"

# attach a managed policy (or use put-inline-policy-to-permission-set for a custom scope)
aws sso-admin attach-managed-policy-to-permission-set \
  --instance-arn "arn:aws:sso:::instance/ssoins-xxxxxxxxxxxx" \
  --permission-set-arn "arn:aws:sso:::permissionSet/ssoins-xxxxxxxxxxxx/ps-readonly" \
  --managed-policy-arn "arn:aws:iam::aws:policy/ReadOnlyAccess"
```

Then assign it to the account and your user, exactly like the admin assignment from before but with the ReadOnly permission set:

```bash
aws sso-admin create-account-assignment \
  --instance-arn       "arn:aws:sso:::instance/ssoins-xxxxxxxxxxxx" \
  --target-id          222222222222 \
  --target-type        AWS_ACCOUNT \
  --permission-set-arn "arn:aws:sso:::permissionSet/ssoins-xxxxxxxxxxxx/ps-readonly" \
  --principal-type     USER \
  --principal-id       "<your-identity-store-user-id>"
```

Identity Center provisions an `AWSReservedSSO_ReadOnly_<hash>` role into the account. Now add a second local profile pointing at the *same* account with the new role:

```ini
[profile ogg-read-only]
sso_session = jed.codes
sso_account_id = 222222222222    # same mail-manager account as `ogg`
sso_role_name = ReadOnly         # the narrower permission set
region = us-east-1
```

That's the payoff: one account, two profiles, two levels of access.

```bash
aws sso login --profile ogg-read-only
aws sts get-caller-identity --profile ogg-read-only
# Arn -> assumed-role/AWSReservedSSO_ReadOnly_<hash>/you@example.com
```

Reach for `ogg` when you're deploying and `ogg-read-only` when you just need to look. (If you later edit a permission set that's *already* assigned somewhere, push the change out with `aws sso-admin provision-permission-set --instance-arn "$INST" --permission-set-arn "$PS" --target-type ALL_PROVISIONED_ACCOUNTS`.)
