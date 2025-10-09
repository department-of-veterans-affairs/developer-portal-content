# Developer Portal Content

## What is it?

This repo acts as an input source for the content of release notes for APIs on the public [Lighthouse Developer Portal](https://developer.va.gov).

## How it works

1. New content is added in a folder structure that matches an expected pattern per each API. Contact your Lighthouse Engagement team if you do not find your folder.
2. The content is written in a Markdown (.md) file, with the name of the file in YYYY-MM-DD.md format.  The YYYY-MM-DD is the date you intend for your API changes to be in production. This is the date that will be displayed with your release note.
3. Content, if it contains additional headings, **must** start at h4's (####). The date, from the name of your Markdown file, is automatically inserted with a h3 (###) heading.
4. A pull request (PR) gets created by the person requesting the new release note.
5. Pull requests (PRs), and update commits to those PRs, push proposed changes to [dev instance](https://dev-developer.va.gov) of the public Lighthouse Developer portal to allow for visual testing.
   After creating the PR:
    * Content is published to [DEV developer.va.gov](https://dev-developer.va.gov/) for visualization.
    * Continue modifying the PR until it displays as you envisioned.
    * Slack [#vaapi-ux-release-notes](https://lighthouseva.slack.com/archives/C03TPJWJ0E6)  channel is notified when the PR is created.
6. Upon UX approval of the PR, merge the PR to `main`.  A GitHub Action will push the content to the Lighthouse Platform Backend (LPB) which will update the content seen on the public [Lighthouse Developer Portal](https://developer.va.gov). This can take up to 10 minutes.  Contact Team Okapi or Lighthouse Engagement team if you don't see it or need assistance.

## How do I write a release note?

**The name of the release note `.md` file, which is also a date, is automatically used as a h3 (###) heading for the release note date.**

See [Lighthouse Guide for Public-facing VA APIs](https://fantastic-spoon-ln1q9vq.pages.github.io/) for release note example templates. These templates show a date, but that date comes from your file name.

You do not need any heading, but if you choose to add one, it **must** start with h4's (####) or higher, in order to interface correctly with the page content. 

## Responsible parties for this repo

- [Team Okapi](https://github.com/orgs/department-of-veterans-affairs/teams/lighthouse-okapi) ([slack](https://lighthouseva.slack.com/archives/C01931CFMTQ)) owns the overall management of this repository and the GitHub Actions that handle the upload of the content to LPB.
- [UX](https://github.com/orgs/department-of-veterans-affairs/teams/lighthouse-ux-approvers) ([slack](https://lighthouseva.slack.com/archives/CDBQ9LN3F)) handles the reviews of content updates and approves pull requests.
- The submitter of the PR will be responsible for implementing any required changes prior to PR approval. Also it will be the submitter's responsibility to merge the PR at the time they would like it to go live. The deploy to production is triggered by the merge of the pull request.
- Lighthouse Engagement team can also assist with questions.

## Additional Instructions 

- [Release Notes for APIs v2](https://confluence.devops.va.gov/pages/viewpage.action?pageId=48077289)

### Using GitHub Web Interface Instructions

### Creating PR after cloning repo locally

1. Clone the [developer-portal-content repository](https://github.com/department-of-veterans-affairs/developer-portal-content) locally.
2. Navigate to the `content` folder and find the sub-folder associated with your API.
3. Add a Markdown (.md) file with the file name being the date of the release note in yyyy-mm-dd format. i.e. 2026-01-15.md. The name of the file is used as the date for the release note.
4. Put in the details of your release note following instructions above.
5. Create a PR. After creating the PR:

    * Content is published to [DEV developer.va.gov](https://dev-developer.va.gov/) for visualization.
    * Continue modifying the PR until it displays as you envisioned.
    * Slack [#vaapi-ux-release-notes](https://lighthouseva.slack.com/archives/C03TPJWJ0E6)  channel is notified when the PR is created.

6. Wait for UX Team approval and/or make changes as necessary until approved. When a release note is being reviewed, the reviewer will put the `eyes` slack emoji on the message. When review is complete, they will add the `white_check_mark` slack emoji.
7. Merge the PR.
8. If the merge is successful, the release note is published on the Lighthouse [developer production portal](https://developer.va.gov).  This can take up to 10 minutes.
