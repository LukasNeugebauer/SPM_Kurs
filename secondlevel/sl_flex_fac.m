function sl_flex_fac
%This is an example of the approach where you take the beta-images or
%simple contrasts (like collapsing over sessions) to the secondlevel. In
%this approach contrasts of interest are specified on the second level
%instead. This approaches takes complexity away on the first level, but
%shifts it to the secondlevel. Flexible factorial is only one way to set
%this up and it's (as the name suggests) very flexible. Another way for
%this model would be to set up a within-subjects ANOVA. You can see this in
%sl_anova
%
%We'll specify and run the model and compute contrasts in the same script

base_dir = get_base_dir;
sl_dir = base_dir.secondlevel;
s_info = get_study_info('secondlevel');
subs = s_info.subs;

%define and create output directory
out_dir = fullfile(sl_dir, 'ANOVA', 'flex_fac');
create_if_necessary(out_dir);

%define conditions for the flexible factorial design
%first column is working memory load
%second column is visibility
%We'll write it as rows and transpose the matrix, because it's easier
conditions = [ones(1, 5), 2 * ones(1, 5);
              1:5, 1:5]'; 

matlabbatch = {};
%define the factors: Subject, Load, Visibility
%We're going to assume Subjects to be independent and to have equal
%variance
matlabbatch{1}.spm.stats.factorial_design.dir = {out_dir};
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'Subject';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
%working memory load is NOT assumed to be independent (i.e. knowing about
%activity under one condition tells you something about activity under the
%other condition), but variances are assumed to be equal as well
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'load';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
%same for visibility
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = 'visibility';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;

%now we have to loop over the subjects to collect the scans
sub_counter = 0;
for s = subs
    sub_counter = sub_counter + 1;
    sub_dir = fullfile(sl_dir, 'ANOVA', sprintf('vp%d', s));
    scans = spm_select('FPList', sub_dir, '^con.*\.nii$');
    %another sanity check
    assert(size(scans, 1) == 10, sprintf('Not the right number of con images in %s\n', sub_dir));
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(sub_counter).scans = cellstr(scans);
    %define which con image corresponds to which of the levels of the two    %factors
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(sub_counter).conds = conditions;
end

%define main effects and interactions
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.inter.fnums = [2, 3];
%throw some defaults at the rest
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

%define batch for estimating the model
spmmat = fullfile(out_dir, 'SPM.mat');
matlabbatch{2}.spm.stats.fmri_est.spmmat = {spmmat};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%Define contrasts: main effects and interaction
me_wm = [-ones(1, 5), ones(1, 5)]; %main effect working memory
me_vis = [-2:2, -2:2]; %main effect visibility
i_wm_vis = me_wm .* me_vis; %interaction is the elementwise product of the main effects

matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
matlabbatch{3}.spm.stats.con.delete = 1;

matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'me_wm';
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = me_wm;
matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = None;

matlabbatch{3}.spm.stats.con.consess{2}.fcon.name = 'me_vis';
matlabbatch{3}.spm.stats.con.consess{2}.fcon.weights = me_vis;
matlabbatch{3}.spm.stats.con.consess{2}.fcon.sessrep = None;

matlabbatch{3}.spm.stats.con.consess{3}.fcon.name = 'i_wm_vis';
matlabbatch{3}.spm.stats.con.consess{3}.fcon.weights = i_wm_vis;
matlabbatch{3}.spm.stats.con.consess{3}.fcon.sessrep = None;

%run that batch!
spm_jobman('run', matlabbatch);

end