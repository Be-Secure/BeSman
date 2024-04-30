# Contributing to BeSman

Thank you for contributing your time and expertise to the BeSman project. This document describes the contribution guidelines for the project.

# Code of Conduct

This project adheres to the Contributor Covenant code of [conduct](https://github.com/Be-Secure/BeSman/blob/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

# Using GitHub Issues

We use GitHub [issues](https://github.com/Be-Secure/BeSman/issues) to track bugs and enhancements. If you have a general question, you can start a discussion [here](https://github.com/Be-Secure/BeSman/discussions).

If you are reporting a bug, please help to speed up problem diagnosis by providing as much information as possible. Ideally, that would include a small sample project that reproduces the problem.

# Reporting Security Vulnerabilities

If you think you have found a security vulnerability in our project please DO NOT disclose it publicly until we’ve had a chance to fix it. Please don’t report security vulnerabilities using GitHub issues, instead please reach out to arun.suresh@wipro.com.

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
