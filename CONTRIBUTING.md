# Contributing to BeSman

Thank you for contributing your time and expertise to the BeSman project. This document provides guidance on BeSman contribution recommended practices. It covers what we're looking for in order to help set expectations and help you get the most out of participation in this project.

# Code of Conduct

This project adheres to the Contributor Covenant code of [conduct](https://github.com/Be-Secure/BeSman/blob/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

# Using GitHub Issues

We use GitHub [issues](https://github.com/Be-Secure/BeSman/issues) to track bugs and enhancements. If you have a general question, you can start a discussion [here](https://github.com/Be-Secure/BeSman/discussions).

If you are reporting a bug, please help to speed up problem diagnosis by providing as much information as possible. Ideally, that would include a small sample project that reproduces the problem.

# Contributing a Pull Request

If you are a new contributor to BeSman, or looking to get started committing to the Be-Secure ecosystem, here are a couple of tips to get started.

First, the easiest way to get started is to make fixes or improvements to the documentation. This can be done completely within GitHub, no need to even clone the project!

You can check the documentations in below links to get a feel of what we are doing,

- [Be-Secure ecosystem](https://be-secure.github.io/Be-Secure/).
- [BeSman Readme](./README.md).
- [BeSman environment repo](https://github.com/Be-Secure/besecure-ce-env-repo).
- [BeSman Playbook repo](https://github.com/Be-Secure/besecure-playbooks-store).

If you feel like you are stuck somewhere, please start a [discussion](https://github.com/Be-Secure/BeSman/discussions) and we will reach out to your queries as soon as we can.

# Maintainers

Maintainers are key contributors to our community project.

For code that has a listed maintainer or maintainers in our [CODEOWNERS](./README.md) file, the Be-Secure team will highlight them for participation in PRs which relate to the area of code they maintain. The expectation is that a maintainer will review the code and work with the PR contributor before the code is merged by the Be-Secure team.

If an an unmaintained area of code interests you and you'd like to become a maintainer, you may simply make a PR against our [CODEOWNERS](./README.md) file with your github handle attached to the approriate area. If there is a maintainer or team of maintainers for that area, please coordinate with them as necessary.

# Proposing a Change

In order to be respectful of the time of community contributors, we aim to discuss potential changes in GitHub issues prior to implementation. That will allow us to give design feedback up front and set expectations about the scope of the change, and, for larger changes, how best to approach the work such that the BeSman team can review it and merge it along with other concurrent work.

If the bug you wish to fix or enhancement you wish to implement isn't already covered by a GitHub issue that contains feedback from the BeSman team, please do start a discussion (either in a new GitHub issue or an existing one, as appropriate) before you invest significant development time. If you mention your intent to implement the change described in your issue, the BeSman team can, as best as possible, prioritize including implementation-related feedback in the subsequent discussion.

Please also look at the [review checklist](./checklist.md) to understand the code standards that we follow.

# Reporting Security Vulnerabilities

If you think you have found a security vulnerability in our project please DO NOT disclose it publicly until we’ve had a chance to fix it. Please don’t report security vulnerabilities using GitHub issues, instead please reach out to arun.suresh@wipro.com.

# Pull Request Lifecycle

1. You are welcome to submit a [draft pull request](https://github.blog/2019-02-14-introducing-draft-pull-requests/) for commentary or review before it is fully completed. It's also a good idea to include specific questions or items you'd like feedback on.
2. Once you believe your pull request is ready to be merged you can create your pull request.
3. When time permits BeSman's core team members will look over your contribution and either merge, or provide comments letting you know if there is anything left to do. It may take some time for us to respond. We may also have questions that we need answers about the code, either because something doesn't make sense to us or because we want to understand your thought process. We kindly ask that you do not target specific team members.
4. If we have requested changes, you can either make those changes or, if you disagree with the suggested changes, we can have a conversation about our reasoning and agree on a path forward. This may be a multi-step process. Our view is that pull requests are a chance to collaborate, and we welcome conversations about how to do things better. It is the contributor's responsibility to address any changes requested. While reviewers are happy to give guidance, it is unsustainable for us to perform the coding work necessary to get a PR into a mergeable state.
5. In some cases, we might decide that a PR should be closed without merging. We'll make sure to provide clear reasoning when this happens. Following the recommended process above is one of the ways to ensure you don't spend time on a PR we can't or won't merge.

## Getting Your Pull Requests Merged Faster

It is much easier to review pull requests that are:

1. Well-documented: Try to explain in the pull request comments what your change does, why you have made the change, and provide instructions for how to produce the new behavior introduced in the pull request. If you can, provide screen captures or terminal output to show what the changes look like. This helps the reviewers understand and test the change.
2. Small: Try to only make one change per pull request. If you found two bugs and want to fix them both, that's awesome, but it's still best to submit the fixes as separate pull requests. This makes it much easier for reviewers to keep in their heads all of the implications of individual code changes, and that means the PR takes less effort and energy to merge. In general, the smaller the pull request, the sooner reviewers will be able to make time to review it.
3. Passing checks: Based on how much time we have, we may not review pull requests which aren't passing our checks. If you need help figuring out why checks are failing, please feel free to ask, but while we're happy to give guidance it is generally your responsibility to make sure that checks are passing. If your pull request changes an interface or invalidates an assumption that causes a bunch of checks to fail, then you need to fix those checks before we can merge your PR.

If we request changes, try to make those changes in a timely manner. Otherwise, PRs can go stale and be a lot more work for all of us to merge in the future.

Even with everyone making their best effort to be responsive, it can be time-consuming to get a PR merged. It can be frustrating to deal with the back-and-forth as we make sure that we understand the changes fully. Please bear with us, and please know that we appreciate the time and energy you put into the project.

# PR Checks

The following checks run when a PR is opened:

1. Contributor License Agreement (CLA): If this is your first contribution to BeSman you will be asked to sign the CLA.
2. Checks: Some automated checks are triggered to verify whether the contents in the pr follow our [guidelines](./checklist.md) and linting.

# Contributing Steps

- Identify an existing issue you would like to work on, or submit an issue describing your proposed change to the repo in question.
- The repo owners will respond to your issue promptly.
- Fork the desired repo, develop and test your code changes.
- Submit a pull request with a link to the issue.

# Branching and Release Strategy

Here we discuss the branching and release strategy for our projects. It ensures a structured approach to development, testing, and release management, leading to stable and reliable software releases.

## Branches

1. **Main Branch (main)**:

    - The `main` branch represents the stable version of the software.
    - Only production-ready code is merged into this branch.
    - Stable releases are tagged from this branch.
  
2. **Development Branch (develop)**:

    - The `develop` branch serves as the integration branch for ongoing development work.
    - Automated testing is conducted when the pull request is raised to the `develop` branch.
    - All feature branches are merged into `develop` via pull requests.
    - Once changes are validated, an RC (Release Candidate) is prepared for testing.

## Pull request process

1. **Feature Development**:

    - Create a feature branch off `develop` for each new feature or bug fix.
    - Name the branch descriptively (e.g., `feature/new-feature`).
    - Implement the changes in the feature branch.

2. **Pull Requests**:

    - Once the feature is ready, open a pull request from the feature branch to `develop`.
    - Ensure the PR title and description are clear and descriptive.
    - Various automated checks will be done on the files changed.
    - Resolve any failing checks promptly.
    - Reviewers will provide feedback and approve the PR.

3. **Release Candidate (RC)**:

    - When `develop` is stable, prepare an RC from the `develop` branch for testing.
    - The RC undergoes end-to-end testing to ensure it meets quality standards.

4. **Stable Release**:

   - After successful testing, the changes will be merged from `develop` into `main`.
   - Merge commit will be tagged as a stable release.

## Other guidelines

1. **Branch Naming**:

    - Use meaningful names for branches (e.g., `feature/issue-123`).
    - Prefix feature branches with `feature/`, bug fix branches with `bugfix/`, etc.

2. **Pull Requests**:

    - Assign appropriate reviewers to PRs.
    - Provide a clear description of the changes in the PR.
    - Link the PR to an existing issue.

3. **Testing**:

    - Test changes locally before opening a PR.

4. **Communication**:

    - Discuss major changes or architectural decisions with the community.
    - Communicate any delays or blockers promptly.
