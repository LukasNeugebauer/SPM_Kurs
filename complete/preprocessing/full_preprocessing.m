%Wrapper script to replicate the whole (pre)preprocessing in one run
%All we need to do is to call the respective subroutines

%pre-preprocessing
dicom_import;
merge_to_4D;
%preprocessing
slice_timing_correction;
realignment;
coregistration;
normalization;
smoothing;