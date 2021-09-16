%Now we bring the T1 and the mean EPI in the same space 
%because we will normalize the EPIs based on a segmentation of the T1 image
%and if they would be in different spaces that would give completely
%nonsensical results

%you know this stuff
base_dir = get_base_dir;
pp_dir = base_dir.preproc;
t1_dir = fullfile(pp_dir, 'T1');
epi_dir = fullfile(pp_dir, 'run1'); %mean epi is in first run folder

%there's only one nii in the t1 dir and the mean epi starts with 'mean'
t1_tmpl = '.*\.nii$';
epi_tmpl = '^mean.*\.nii$';

%collect the files
t1_file = spm_select('FPList', t1_dir, t1_tmpl);
epi_file = spm_select('FPList', epi_dir, epi_tmpl);

disp(t1_file);
disp(epi_file);
%create the matlabbatch
matlabbatch = {};
matlabbatch{1}.spm.spatial.coreg.estimate.ref = {epi_file}; %we coregister the T1 TO the EPI, so the EPI is the reference
matlabbatch{1}.spm.spatial.coreg.estimate.source = {t1_file};
matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi'; %normalized mutual information
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

%and run it
spm_jobman('run', matlabbatch);