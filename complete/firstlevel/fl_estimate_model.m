function fl_estimate_model
%Now we actually estimate the betas for the firstlevel models
%It would be a lot easier to do it in the same function as the model
%specification, but it's good to review the first level model first before
%estimating it

s_info = get_study_info('rose');
subs = s_info.subs;

base_dir = get_base_dir;
fl_dir = base_dir.firstlevel;

matlabbatch = {};
counter = 0;

for s = subs
    counter = counter + 1;
    sub_dir = fullfile(fl_dir, sprintf('VP%d', s), 'firstlevel');
    spmmat = fullfile(sub_dir, 'SPM.mat');
    matlabbatch{counter}.spm.stats.fmri_est.spmmat = {spmmat};
    matlabbatch{counter}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{counter}.spm.stats.fmri_est.method.Classical = 1;
end

spm_jobman('run', matlabbatch);

end