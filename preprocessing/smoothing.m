function smoothing
%This is the last part before the firstlevel analysis: Smoothing the niftis
%with a Gaussian smoothing kernel to ensure uniform distribution of errors
%and reduce number of independent elements (resels)

%Speficy the size of the smoothing kernel
FWHM = 6;

%you know this stuff
base_dir = get_base_dir;
pp_dir = base_dir.preproc;

%collect all the files
n_runs = 3; 
scans = cell(1, n_runs);
%sprintf template for the directories
dir_tmpl = 'run%d';
%regex template for the EPI files, using the normalized epis
epi_tmpl = '^warun.*\.nii';

%collect epis
epis = cell(1, 3);
for r = 1:n_runs
    direc = fullfile(pp_dir, sprintf(dir_tmpl, r));
    files = spm_select('ExtFPList', direc, epi_tmpl);
    epis{r} = cellstr(files);
end

%put them all in one cell array
all_files = cat(1, epis{:});

%create and fill the batch
matlabbatch = {};
matlabbatch{1}.spm.spatial.smooth.data = all_files;
matlabbatch{1}.spm.spatial.smooth.fwhm = [FWHM FWHM FWHM];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

%run the batch
spm_jobman('run', matlabbatch);

end