# Launch Task Guide

Read this before explaining builder launch tasks. Each task lists what it is, why it matters, how to complete it, and how the builder knows it is done. Include only the tasks that apply to the project. Dashboard menus change over time, so describe where to go in general terms and link the provider's own documentation when unsure.

## Domains and Hosting

### Connect the domain and subdomains
- **What:** Point the domain (and any subdomains such as `app.` or `blog.`) at the host.
- **Why:** Until the DNS records exist, visitors cannot reach the site at its real address.
- **How:** In the Vercel project (or chosen host), open the domain settings and add each domain and subdomain. The host shows the DNS records it needs. Add those records at the domain registrar.
- **Done when:** Each domain loads the site over HTTPS, and the host shows the domain as verified.

### Set production environment variables
- **What:** Add the production API keys and secrets to the host's environment settings.
- **Why:** Secrets never live in the code, so the deployed site cannot reach Supabase, payments or email without them.
- **How:** In the host's project settings, add each variable listed in the project's `.env.example` with its production value. Redeploy afterward.
- **Done when:** The deployed site signs in, saves data and sends email without errors.

## Email

### Add email DNS records and verify the sending domain
- **What:** Add SPF, DKIM and DMARC records for the sending subdomain, and verify it with the email provider.
- **Why:** Without these records, password resets and confirmations land in spam or are rejected.
- **How:** In the email provider (such as Resend or Postmark), add the sending domain. It shows the exact records. Add them at the registrar, then start DMARC at `p=none`.
- **Done when:** The provider marks the domain as verified, and a test password reset arrives in the inbox, not spam.

## Accounts

### Create sign-in provider apps
- **What:** Register the app with each sign-in provider and add the credentials to Supabase.
- **Why:** Provider buttons do not work until each provider knows the app's address.
- **How:** Create an OAuth client in Google Cloud, Apple Developer, Microsoft Entra, GitHub or Discord as applicable. Use the callback URL that Supabase shows in its authentication provider settings, then paste the client ID and secret into Supabase.
- **Done when:** Each provider button signs a test user in on the production domain.

### Set up an SMS provider
- **What:** Connect an SMS provider (such as Twilio) to Supabase.
- **Why:** Phone sign-in and text message codes need it.
- **How:** Create the provider account, buy or verify a sending number, and add the credentials in Supabase's phone authentication settings. Restrict sending to the countries the app serves.
- **Done when:** A test phone number receives a code and signs in.

### Review Supabase production settings
- **What:** Confirm the Supabase project is ready for real users.
- **Why:** Development defaults (built-in email, localhost redirect URLs) break or weaken production.
- **How:** Set the site URL and redirect URLs to the production domain, connect custom SMTP for email, turn on leaked password protection if the plan includes it, and run the Security Advisor and Performance Advisor.
- **Done when:** Both advisors report no issues and sign-in emails link to the production domain.

## Payments

### Switch payments to live mode
- **What:** Replace test payment keys with live keys and register the production webhook.
- **Why:** Test keys cannot take real payments, and a missing webhook means orders never complete.
- **How:** In the payment provider's dashboard, activate the account, copy the live keys into the host's environment settings, and add a webhook endpoint pointing to the production webhook URL. Copy its signing secret into the environment settings too.
- **Done when:** A real low-value purchase completes, appears in the app, and can be refunded.

## Search and Sharing

### Submit the sitemap
- **What:** Tell Google and Bing where the sitemap is.
- **Why:** It helps new pages get indexed faster.
- **How:** Add and verify the site in Google Search Console and Bing Webmaster Tools, then submit `/sitemap.xml` in each.
- **Done when:** Both tools show the sitemap as successfully read.

### Check real-world performance
- **What:** Run PageSpeed Insights on the deployed public pages, then watch the Core Web Vitals report.
- **Why:** Local tests cannot measure real networks, devices or hosting.
- **How:** Enter each main public URL at pagespeed.web.dev and check the mobile and desktop scores. After a few weeks of traffic, open the Core Web Vitals report in Search Console.
- **Done when:** Mobile and desktop scores are 90+ and the Core Web Vitals report shows good URLs.

### Check link previews
- **What:** Confirm shared links show the right title, description and image.
- **Why:** Social apps cache previews, so a wrong first preview can stick.
- **How:** Paste key URLs into the Facebook Sharing Debugger and LinkedIn Post Inspector, and refresh their cache if needed.
- **Done when:** Each preview shows the correct image and text.

## Content and Legal

### Fill in open legal fields
- **What:** Replace every labeled field in the legal pages (such as "[Company legal name]").
- **Why:** Legal pages with placeholders are not valid, and published placeholders look unprofessional.
- **How:** Search the legal pages for `[`, fill in each field, and have a lawyer review the pages before launch.
- **Done when:** No placeholders remain and the review is complete.

### Replace content placeholders
- **What:** Replace marked placeholder content such as "[Customer quote]".
- **Why:** The site may only show real content.
- **How:** Search the project for `[` in page content and replace each placeholder with real, approved content, or remove the section.
- **Done when:** No placeholders remain in published pages.

### Complete humans.txt
- **What:** Fill in the TEAM and THANKS sections of `/humans.txt`.
- **Why:** It credits the people behind the site.
- **How:** Edit the file and add the names, roles and links each person agrees to share.
- **Done when:** No placeholders remain in the file.

### Publish security.txt
- **What:** Confirm a security contact so `/.well-known/security.txt` can be published, and renew it yearly.
- **Why:** Security researchers use it to report problems privately.
- **How:** Choose a monitored address (such as security@ the domain), add it to the file with an `Expires` date within one year, and set a reminder to renew.
- **Done when:** The file loads on the live site with a valid contact and future expiry date.

## Testing

### Test on real devices and browsers
- **What:** Use the main flows on real phones, tablets and computers.
- **Why:** Emulators miss touch, keyboard and rendering differences.
- **How:** Test on at least one iPhone, one Android phone, and Windows and macOS computers, or use a service such as BrowserStack.
- **Done when:** Every main flow works on each device and browser in the support list.

### Test with screen readers
- **What:** Complete the main flows with VoiceOver, NVDA, JAWS and TalkBack.
- **Why:** Automated tools catch only part of what blocks screen reader users.
- **How:** Turn on each screen reader and complete sign-up, the main task and checkout (if any) without looking at the screen.
- **Done when:** Every flow can be completed and every control is announced with a clear name.

## Optional

### Submit to the HSTS preload list
- **What:** Ask browsers to always use HTTPS for the domain.
- **Why:** It closes the gap on a visitor's very first request.
- **How:** Confirm every subdomain supports HTTPS, then submit the domain at hstspreload.org. Removal takes months, so only do this when certain.
- **Done when:** The site shows as preloaded on hstspreload.org.

### Make the site an installable PWA
- **What:** Add offline support for public pages and an install option.
- **Why:** Users can open the app from their home screen.
- **How:** Ask Claude to add a service worker that caches only public pages and the app shell, following the storage rules.
- **Done when:** The browser offers to install the site and public pages load offline.

### Block disposable email addresses
- **What:** Reject throwaway email services at sign-up.
- **Why:** It reduces repeat sign-ups in apps with free trials or rewards.
- **How:** Ask Claude to add a check against a maintained disposable email blocklist.
- **Done when:** A disposable address is rejected with a clear message.
