---
title: "Forms for static sites - stage 1"
date: 2020-02-12T16:20:43-08:00
description: "two basic options with average results"
tags: ["jamstack"]
---

In the first rendition of this site, I have enabled two services for form
submission.

I've been very excited to try some of the ideas the [JAMstack](jamstack.org) supports.
Along with current projects and side ideas, hopefully this becomes a place to share
some of that journey.
Please checkout the [colophon](/colophon) for a current description of process and workflow.

1. [Contact Form](#contact-form)
1. [Email Newsletter](#email-newsletter-subscribe-form)

---

## Contact Form

For the initial release of this site I am using [formspree](formspree.io) for
the contact form.
This form is fully hosted and is rather limited in functionality.

### What it does well

✅ Get a form action url, [put it in a
form](https://github.com/jedschneider/jed.codes/commit/bf9951a0a31abd79d0b319868fb6cac516496847#diff-dc609f72c7ab0d8cb0992709d3ccb7cdR12), use it in your site.

✅ Add the inputs and (I assume) options you want, there is no configuration on the Formspree side, but that means no "server side" validation either.

✅ Recaptcha validation on submissions seems like a nice spambot prophylactic.

### What seems limiting

❌ low limits on form submissions for the free tier

❌ limited options for plugin integration for the free tier.

❌ $10/mo sounds like a lot to pay for handling a single form action. I'd like
to see a $2/mo plan with per submission rates. At the $10 price point, it feels
like this could be reasonably easily constructed using API Gateway, Lambda, and SNS.

❌ manual redirect click to return the site seems limiting. I'd like to see an option on the Formspree side to specify the return landing page.

---

## Email Newsletter Subscribe Form

For the newsletter we've chosen to start with [Mailchimp](https://mailchimp.com) to handle newsletter signup.
As the obvious market leader they have an obvious advantage in the tools offered for the communication platform.
For my purposes, what I'm mostly interested in is the privacy and anti-spam integration they provide for email subscribers.
Mailchimp offers several integration options, but the most obvious to start with
is the [_embedded form_](https://mailchimp.com/help/host-your-own-signup-forms/) option which allows direct form-data submission to their web service.

### What it does well

✅ Handles anti-spam and GDPR regulations more or less out of the box.

✅ Unstyled form option allows easy styling.

✅ Unstyled double opt-in, email confirmation flow works as advertised.

### What seems limiting

❌ Like Formspree, the entry point back into the site is a manual user action to click back to the site.
I believe higher cost plans have better handling to improve the brand awareness.
However, at the price points available, it might be much more affordable to handle the form submission with a custom serverless function that delegates to the MailChimp API.

❌ Like Formspree, the entry point back into the site is a manual user action to click back to the site.
This is actually nice for the confirmation email as long as you don't mind the cross-branding or are willing to pay more for less Mailchimp branding.

Check it out on the [subscribe](/subscribe) page.

