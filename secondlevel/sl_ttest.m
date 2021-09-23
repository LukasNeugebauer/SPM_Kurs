function sl_ttest
%Compute a second level t-test on the con-images of the main effect working
%memory, i.e. 2back > 1back
%This is an example for an analysis where the contrast of interest is
%specified on the first level and the second level is really simple, only a
%voxel-wise t-test of the subject level con-images against 0
%
%We're going to specify and estimate it as well as compute the contrast at 
%the same time

%the usual
base_dir = get_base_dir;
sl_dir = base_dir.secondlevel;
s_info = get_study_info('secondlevel');

%define the output directory
out_dir = fullfile(sl_dir, 'OneSampleTTest_ME_WM', 'me_wm_ttest');
create_if_necessary(out_dir);

%collect the files
con_dir = fullfile(sl_dir, 'OneSampleTTest_ME_WM');
subs = s_info.subs;
scans = cell(length(subs), 1);
counter = 0;
for s = subs
    counter = counter + 1;
    sub_dir = fullfile(con_dir, sprintf('vp%d', s));
    con_image = spm_select('FPList', sub_dir, '^con.*\.nii$');
    %here's another general tip:
    %sanity checks in between are a good idea because they enable you to
    %catch mistakes when they happen and you can write helpful messages to
    %yourself instead of weird errors that SPM or MATLAB throw at you
    assert(~isempty(con_image), sprintf('No con-image in this folder: %s\n', sub_dir));
    scans{counter} = con_image;
end

%empty matlabbatch
matlabbatch = {};
%output directory
matlabbatch{1}.spm.stats.factorial_design.dir = {out_dir};
%the scans we're going to compute the t-test on
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = scans;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;


%we're going to specify the second batch for actually estimating the model
%at the same time
%SPM is going to write a SPM.mat-file in the out_dir of the first step.
%that's what we need as input for the second step in which we estimate the
%model. All the info is in this file, so the second step is really easy to
%code
spmmat = fullfile(out_dir, 'SPM.mat');
matlabbatch{2}.spm.stats.fmri_est.spmmat = {spmmat};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


%and even though we just have one con-image per subject, we still need to
%compute the contrasts. A 1 is the main effect, i.e. 2back > 1back and a -1
%gives the opposite (1back > 2back)
matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
matlabbatch{3}.spm.stats.con.delete = 1;
%2back > 1back
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = '2back>1back';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = '1back>2back';    
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = -1;
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

%Now we just need to run the batch
spm_jobman('run', matlabbatch);


end