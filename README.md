# EEGsourceLocalizer

Developer(s) Name: Leila Mousapour
Date of project start: September 26, 2020

This scientific software will implement several techniques to map EEG signals from electrode space to source space.(EEG source localization)

The folders and files for this project are as follows:

docs - Documentation for the project
refs - Reference material used for the project, including papers
src - Source code
test - Test cases

This software is implemented in MATLAB and built on Fieldtrip toolbox.

# EEGsourceLocalizer User Guid

The problem statement for this software can be found in: 
https://github.com/LeilaMousapour/Brain-Computer-Interface-/blob/master/docs/ProblemStatement/ProblemStatement.pdf
<<<<<<< HEAD

The systerm requirement specification document that includes the theoretical background can be found in: 
https://github.com/LeilaMousapour/Brain-Computer-Interface-/blob/master/docs/SRS/SRS.pdf

The validation and verification plan and report are respectively documented in:
https://github.com/LeilaMousapour/Brain-Computer-Interface-/blob/master/docs/VnVPlan/SystVnVPlan/SystVnVPlan.pdf
and 
https://github.com/LeilaMousapour/Brain-Computer-Interface-/blob/master/docs/VnVReport/SystVnVReport/SystVnVReport.pdf

The modular desing of the software is docuented in: 
https://github.com/LeilaMousapour/Brain-Computer-Interface-/tree/master/docs/Design

For individuals new to source localization refereing to this toturial is highly recommended:
https://www.fieldtriptoolbox.org/tutorial/beamformer/


For running EEGSourceLocalizer on a system (Windows/Mac) follwoing toolboxed should be added to the MATLAB current path:
- Fieldtrip (https://github.com/fieldtrip/fieldtrip)
- EEGLab (https://sccn.ucsd.edu/eeglab/download.php)


To use EEGsourceLocalizer:

0- Download or clone src folder on your system

1- Add both Fieldtrip and eeglab toolboxed to your MATLAB current path

2- Run the main.m as a demo of how you can use the software. This module will use an already provided EEG data and corresponding electrode location and MRI.

3- Check the output folder for the saved result

** If you are willing to run the system tests (based on VnV plan), you can simply go to the test folder under EEGsL and run any of the scripts and the results would be generated.

should use pytest library python for execution.


