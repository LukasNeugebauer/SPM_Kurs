function slice_timing_correction
%Slices per volume are not all collected at the same time
%Whether or not we actually need to correct for that is on another page
%But here's how you do it

%we use information that is hardcoded elsewhere, so that it's only
%hardcoded ONCE. This is a lot less susceptible to mistakes
s_info = get_study_info('preproc');
TR = s_info.TR;
n_slices = s_info.n_slices;
TA = TR - (TR / n_slices);
slice_order = n_slices:-1:1;
ref_slice = floor(n_slices / 2);

%the usual path info
base_dir = get_base_dir;
pp_dir = base_dir.preproc;

%collect all the files
%they have to be in a 1xSession Cell array, with every entry having all the
%scans for one session
%we're going to stop writing out all the path names and think more like a programmer
n_runs = 3; 
%create empty cell of size 3
scans = cell(1, n_runs);
%sprintf template for the directories
dir_tmpl = 'run%d';
%regex template for the files
file_tmpl = '^run.*\.nii';

for r = 1:n_runs
    direc = fullfile(pp_dir, sprintf(dir_tmpl, r));
    files = spm_select('ExtFPList', direc, file_tmpl);
    scans{r} = cellstr(files);
end

%this time no counter because all the runs go into one module
%we already have all the information (scans + info about them), now we just
%need to put them in the batch
matlabbatch = {};
matlabbatch{1}.spm.temporal.st.scans = scans;
matlabbatch{1}.spm.temporal.st.nslices = n_slices;
matlabbatch{1}.spm.temporal.st.tr = TR;
matlabbatch{1}.spm.temporal.st.ta = TA;
matlabbatch{1}.spm.temporal.st.so = slice_order;
matlabbatch{1}.spm.temporal.st.refslice = ref_slice;
matlabbatch{1}.spm.temporal.st.prefix = 'a';

%and run the batch
spm_jobman('run', matlabbatch);