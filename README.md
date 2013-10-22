ITK Software Guide
==================

This is the source code for the ITK Software Guide. A combination of CMake
Superbuild infrastructure, python extraction scripts, and LaTeX formatting
needed to render the entire ITK Software Guide. Further instructions on building
the ITK Software Guide can be found in SoftwareGuide/README.txt.

TODO: Perhaps the instructions on configuring and building the ITK Software
Guide should be moved here to make them more visible.

How to Contribute to the ITK Software Guide
===========================================

The contribution process mirrors the [ITK contribution
process](http://itk.org/Wiki/ITK/Git/Develop) with the exception of the clone
url:

    http://itk.org/ITKSoftwareGuide.git

The basic knowledge of git underpins the contribution process. A very concise
but very handy guide to git can be found
[here](http://rogerdudler.github.io/git-guide/).

Contribution Process Overview
-----------------------------

The following commands illustrate patch submission to Gerrit:

    git clone http://itk.org/ITKSoftwareGuide.git
    cd ITKSoftwareGuide
    ./Utilities/SetupForDevelopment.sh
    git checkout -b MyTopic
    # make changes to local file(s)
    git add -- changedFileName
    git commit
    git gerrit-push

Further Details on Contributing Patches Through Git and Gerrit
--------------------------------------------------------------

After cloning the repository on your local machine for the first time, it is
necessary to provide git with your basic identity details in order to enable
the correct process of contributing to source code. The SetupForDevelopment.sh
script does just that along with giving you an opportunity to change some
other basic settings.

Before you start making changes, a new branch needs to be created with the given
name: "git checkout -b branchName". Use the editor of your choice to make the
changes to the file(s).

When you are satisfied with your changes use "git add -- fileName" to stage the
file to commit. The outcome of this process will result in a patch submitted
to Gerrit code review.

When you run "git commit" you'll be presented with a VIM editor window to type
your commit message. The commit message must be started with a one of the
following standard prefixes:

 - BUG: - fix for runtime crash or incorrect result
 - COMP: - compiler error or warning fix
 - DOC: - documentation change
 - ENH: - new functionality
 - PERF: - performance improvement
 - STYLE: - no logic impact (indentation, comments)
 - WIP: - work In Progress not ready for merge

TODO: These options are missing from msg_gerrit() in ./git/hooks/commit-msg
file.

Following the prefix, separated by the colon and a space, type the brief
one-line description of the patch. Type a more detailed description of the
patch after a blank line. When you save and close the commit message file
you will see the change ID at the bottom of the commit message.

The process of submitting a patch is ended by running "git gerrit-push" command
which will provide a summary message from Gerrit including the URL for the
patch page on Gerrit web interface. It is important to add reviewers to your
patch.

The code is merged through the *Submit Patch Set* button in Gerrit after it
has been approved.

Some Helpful Git Commands
-------------------------

 - "git status" will report at any time which files have been modified.
 - "git branch" will list the branches available in the local repository.
 - "git checkout -- fileName" will revert the local changes made to the
   specified file.
 - "git blame -- fileName" will report the source of contributors line-by-line.
 - "git commit --amend" will revise a commit or commit message to respond to
   reviewer comments.
 - "git rebase -i HEAD~3" will give an opportunity to squash or revise the
   previous three commits.
 - "git grep searchTerm" will list all occurrences of the searchTerm in the
   source tree.
 - "get help gitCommandName" will show the documentation on the gitCommandName
   in HTML format.

A one-page Git-ITK cheat-sheet is available
[here](http://www.itk.org/Wiki/images/1/10/GitITKCheatSheet.pdf).

Further Help
------------

A lot of helpful video-guides can be found on the [ITK Bar Camp](
http://insightsoftwareconsortium.github.io/ITKBarCamp-doc/index.html) site.
