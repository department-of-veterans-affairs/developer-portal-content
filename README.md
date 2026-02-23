# Developer Portal Content

## What is it?

This repo acts as an input source for the content of release notes for APIs on the [Lighthouse Developer Portal](https://developer.va.gov).

## How it works

1. New content is added in a folder structure that matches an expected pattern per each API.
2. A pull request gets created by the person requesting the new release note.
3. Pull requests, and update commits to those PRs, push proposed changes to [dev](https://dev-developer.va.gov) to allow visual testing.
4. Upon PR approval and merge to `main` a GitHub Action will push the content to the Lighthouse Platform Backend (LPB) which will update the content pulled into the production instance of [developer portal](https://developer.va.gov).

### Responsible parties

- [Team Okapi](https://github.com/orgs/department-of-veterans-affairs/teams/lighthouse-okapi) ([slack](https://lighthouseva.slack.com/archives/C01931CFMTQ)) owns the overall management of this repository and the GitHub Actions that handle the upload of the content to LPB.
- [UX](https://github.com/orgs/department-of-veterans-affairs/teams/lighthouse-ux-approvers) ([slack](https://lighthouseva.slack.com/archives/CDBQ9LN3F)) handles the reviews of content updates and approves pull requests.
- The submitter of the PR will be responsible for implementing any required changes prior to PR approval. Also it will be the submitter's responsibility to merge the PR at the time they would like it to go live. The deploy to production is triggered by the merge of the pull request.

## More Resources

- [Release Notes for APIs v2](https://confluence.devops.va.gov/pages/viewpage.action?pageId=48077289)
