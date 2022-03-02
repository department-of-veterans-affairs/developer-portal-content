# Developer Portal Content
## What is it?

This repo acts as a source for content changes for release notes for APIs on the [Lighthouse Developer Portal](https://developer.va.gov).

## How it works

1. New content is added in a folder structure that matches an expected pattern per each API.
2. A pull request gets created and reviewed.
3. Upon merge to `main` a GitHub Action will push the content to the Lighthouse Consumer Management Service which will update the content pulled into the developer portal.
