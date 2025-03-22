Contributing to the ITK Software Guide with Git and GitHub
----------------------------------------------------------

The contribution process mirrors the [ITK contribution process](https://github.com/InsightSoftwareConsortium/ITK/blob/master/CONTRIBUTING.md) with the exception of the clone url:

   https://github.com/InsightSoftwareConsortium/ITKSoftwareGuide.git

A basic knowledge of [Git] underpins the contribution process. A concise
but handy guide to [Git] can be found
[here](http://rogerdudler.github.io/git-guide/).


Contributing Patches with Git and GitHub
----------------------------------------

To obtain a copy of the project sources, run

```sh
  git clone https://github.com/InsightSoftwareConsortium/ITKSoftwareGuide.git
```

After cloning the repository on your local machine for the first time, it is
necessary to provide Git with your authorship identity details. The
`ITKSoftwareGuide/Utilities/SetupForDevelopment.sh` script does just that, and
it provides an opportunity to change other basic settings.

Before you start making changes, a new branch needs to be created with a name
that describes the change's topic: `git checkout -b topic-name`.

Next, use the editor of your choice to make the changes to the file(s).

When you are satisfied with your changes, use `git add -- fileName` to stage the
file to commit.

When you run `git commit`, you will be presented with a [VIM] editor window to
type your commit message. The commit message must start with a one of the
following standard prefixes:

  * `BUG`: Fix for runtime crash or incorrect result
  * `COMP`: Compiler error or warning fix
  * `DOC`: Documentation change
  * `ENH`: New functionality
  * `PERF`: Performance improvement
  * `STYLE`: No logic impact (indentation, comments)
  * `WIP`: Work In Progress not ready for merge

Following the prefix, separated by a colon and a space, type a brief one-line
description for the patch. Type a more detailed description of the patch after
a blank line.

Submit the patch for peer review by running the `git review-push` command.
This will provide a summary message that includes a URL to view the changes. If
you are logged into [GitHub], there will also be a green button to create a
[Pull Request].

The automated continuous integration builds will build your patch. If the
*CircleCI* build fails, click the CircleCI and CDash `Details` link to find
additional information on why the build failed. If the CircleCI build
succeeds, click on the CDash status `Details` link. Click the yellow package
icon to obtain links to the rendered Software Guide PDF's for inspection.

Peers will review the patch, and you will receive emails with review comments.
Reply to the comments, and follow-up with edits for your change with:

```sh
  git add -- fileName
  git commit --amend
  git review-push --force
```

After the patch has been approved by code reviews and passes all continuous
integration tests, a community member will merge the patch.

Thank you for contributing to the open science image analysis community!

Some Helpful Git Commands
-------------------------

  * `git status` will report at any time which files have been modified.
  * `git branch` will list the branches available in the local repository.
  * `git checkout -- fileName` will revert the local changes made to the
    specified file.
  * `git blame -- fileName` will report the source of contributors
    line-by-line.
  * `git commit --amend` will revise a commit or commit message to respond to
    reviewer comments.
  * `git rebase -i HEAD~3` will give an opportunity to squash or revise the
    previous three commits.
  * `git grep searchTerm` will list all occurrences of the searchTerm in the
    source tree.
  * `get help gitCommandName` will show the documentation on the
    `gitCommandName` in HTML format.

<!-- Uncomment these lines after the ITK repository has finished migration to GitHub

*A one-page Git-ITK cheat-sheet is available [here](https://www.itk.org/Wiki/images/1/10/GitITKCheatSheet.pdf).
-->


[Git]: https://git-scm.com/
[VIM]: https://www.vim.org/
[GitHub]: https://github.com/
[Pull Request]: https://help.github.com/articles/about-pull-requests/
