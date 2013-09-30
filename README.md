ITKSoftwareGuide
================

This is the source code for the ITK Software Guide.

A combination of CMake Superbuild infrastructure, python extraction scripts,
and LaTeX formatting needed to render the entire users guide.

Contribute
----------

The contribution process mirrors the [ITK contribution
process](http://itk.org/Wiki/ITK/Git/Develop) with the exception of the clone
url:

    http://itk.org/ITKSoftwareGuide.git

Also, code is merged through the *Submit Patch Set* button in Gerrit after it
has been approved.

In summary:

    git clone http://itk.org/ITKSoftwareGuide.git
    cd ITKSoftwareGuide
    ./Utilities/SetupForDevelopment.sh
    git checkout -b MyTopic
    # make changes
    git add -- file/that/changed
    git commit
    git gerrit-push
