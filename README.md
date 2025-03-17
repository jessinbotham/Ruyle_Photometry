# Ruyle_Photometry
Matlab codes for wireless photometry analysis of NTS activity for Ruyle et al., 2025

The most recent version of these codes can be found in the **MatlabCodes folder**

Scripts are written for batch processing and analysis of Amuza Telefipho photometry data.

Raw data files should be saved as .txt files with the first two identifiers separated by an underscore delimiter. 
Folder for analysis and codes should be saved in the matlab workspace before running

**REQUIREMENTS:**
Event data is extracted using the pMAT suite. For use of these codes with event data:
Start by downloading Matlab and installing pMAT.
Installation and user guide can be found here: https://github.com/djamesbarker/pMAT 
Codes are intended to be used in the order described below. 
Enter 'clear' in the command window before running each script.

**WORKFLOW:**

**_1. RawDataPreprocessing.m_**
   Compiles and cleans a folder of Telefipho raw data .txt files with event pairing denoted as voltage change (<3V) in channel 2 and saved in .txt format 
   1. The user is prompted to select the folder for analysis
   2. The user is prompted to select the number of rows to remove from the file to account for artifacts at the start of the recording (100 Hz sampling rate).
      Default is 3000 or 5 min.
   3. For Telefipho users, static artifacts coded as 32768 are removed from the signal and filled with the next detected value. If more than 500 occurrences are found, then users will be warned at the end with a popup indicating which files should be reexamined for inconsistencies and extensive loss of signal
   4. Underscore delimiters in the filename are used to generate filenames for .csv files created by this script
   5. The _SignalFile consists of the raw signal data with artifacts removed aligned to time and a control channel is generated using an double exponential fit
   6. The _EventData consists of the events coded as TRUE or FALSE indicated by a drop in voltage (<3V) in the second channel during recording. Events are aligned to time
   8. The _SignalFile and _EventData for each .txt file are saved for processing with pMAT. A copy of the signal files are also saved to a separate folder, Signal Files, for SpontaneousEvent_BatchProcessor.m
   9. The user is notified once the file saves are completed. A warning message including files with a large number of artifacts notifies the user of file abnormalities if present.

IMPORTANT: Files extracted in the previous step should be isolated to the time of interest (noted in event pairing in Ch. 2) using the pMAT suite in Matlab. pMAT output files for this paper were extracted at the sampling rate (100 Hz) at -30:+90s relative to T=0 (event timestamp). Underscore delimiters defining the ID and conditions (1 delimiter max) are necessary for subsequent steps. 

**_2. TrialTraceData_compiler.m_** and versions
   These scripts are meant to be used AFTER extracting trail trace data (behavioral event paired) in pMAT suite. When using pMAT, underscore delimiters for file naming is necessary to maintain identifiers.
   The pMAT suite will save trial trace data to a separate 'Data' folder which should be used when running these scripts.
   1. TrialTraceData_compiler.m prompts users to locate the Data folder containing trial trace data.
   2. Users designate a filename for the summary file to be created with identifiers and trial data aligned into a single sheet
   3. Users are prompted to enter the time parameters (Start Time, Increment, End Time) used to isolate events in pMAT (Pre Time (s), Bin Constant, Post Time (s)). NOTE: Converting the Bin Constant into Increments (s) users should note the sampling frequency. e.g. For 100 hz sampling, a Bin Constant of 50 equals an Increment of 0.5 s
   5. Summary File saved with this script compiles the df/f and z-scored data into a single excel file. from all subects
   6. A pop-up window notifies the user that the compilation is completed

**_3. NTS_AUC.m_** and versions
  Uses the z-scored data obtained in the previous step to generate AUC values 
  1. Import the z-score data into Matlab workspace as a vector
  2. Modify changeable variables as desired in the code before running. Ensure matching of variable names and appropriate output file naming. 
