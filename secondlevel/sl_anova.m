function sl_anova
%This is a way to set up the same model as in sl_flex_fac, but without the
%(in my opinion) unnecessarily complex way of setting it up. Essentially
%it's a within-subject ANOVA because we want to know about the differences
%between the conditions within subjects

base_dir = get_base_dir;
sl_dir = base_dir.secondlevel;
s_info = get_study_info('secondlevel');
subs = s_info.subs;

%define and create output directory
out_dir = fullfile(sl_dir, 'ANOVA', 'rm_anova');
create_if_necessary(out_dir);

%regular expression for con images
con_regex = '^con_[0-9]{4}\.nii$';

matlabbatch = {};
counter = 0;

matlabbatch{1}.spm.stats.factorial_design.dir = {out_dir};

%this is only the part for the subject info, we'll fit it into the
%matlabbatch later
fsubject = [];
for s = subs
    counter = counter + 1;
    sub_dir = fullfile(sl_dir, 'ANOVA', sprintf('vp%d', s));
    epis = spm_select('FPList', sub_dir, con_regex);
    fsubject(counter).scans = cellstr(epis);
    fsubject(counter).conds = 1:10;
end

%anovaw for anova within subjects
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject = fsubject;
%we assume factors to be dependent. We do assume independence between
%subjects, but that is implicitely defined because we run a within-subject
%ANOVA
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.dept = 1;
%we assume variances between factors to be equal
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.variance = 0;
%for the rest, the defaults are okay
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

%estimate the model
spmmat = fullfile(out_dir, 'SPM.mat');
matlabbatch{2}.spm.stats.fmri_est.spmmat = {spmmat};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%contrasts
me_wm = [-ones(1, 5), ones(1, 5)];
me_vis = [-2:2, -2:2];
i_wm_vis = me_wm .* me_vis;

matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
matlabbatch{3}.spm.stats.con.delete = 1;

matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'me_wm';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = me_wm;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'None';

matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'me_vis';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = me_vis;
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'None';

%F-contrast because I have no clue what the expected direction is
matlabbatch{3}.spm.stats.con.consess{3}.fcon.name = 'i_wm_vis';
matlabbatch{3}.spm.stats.con.consess{3}.fcon.weights = i_wm_vis;
matlabbatch{3}.spm.stats.con.consess{3}.fcon.sessrep = 'None';

keyboard

%run the batch
spm_jobman('run', matlabbatch);

end