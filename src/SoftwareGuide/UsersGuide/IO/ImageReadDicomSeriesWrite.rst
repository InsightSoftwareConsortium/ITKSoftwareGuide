The source code for this section can be found in the file
``ImageReadDicomSeriesWrite.cxx``.

This example illustrates how to read a 3D image from a non DICOM file
and write it as a series of DICOM slices. with some changed header
information. Header

Please note that modifying the content of a DICOM header is a very risky
operation. The Header contains fundamental information about the patient
and therefore its consistency must be protected from any data
corruption. Before attempting to modify the DICOM headers of your files,
you must make sure that you have a very good reason for doing so, and
that you can ensure that this information change will not result in a
lower quality of health care to be delivered to the patient.
