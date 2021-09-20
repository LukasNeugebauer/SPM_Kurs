function fl_design_spec
%Design specification for the firstlevel analysis
%Runs model specification, but doesn't estimate it!

%collect study info
s_info = get_study_info('rose');
TR = s_info.TR;
n_slices = s_info.n_slices;
subs = s_info.subs;

%hardcoded study info, will also move to function in the future
n_runs = 3;
runs = 1:n_runs;
duration = 7.7; %20 seconds is 7.7 scans with a TR of 2.6 s
%there are 2 working memory and 5 visibility conditions
%and we will loop over working memory first
%please do not actually hardcode all of it like that... :D
n_wm = 2;
n_vis = 5;

%collect path info
base_dir = get_base_dir;
fl_dir = base_dir.firstlevel;

%regex templates
rp_tmpl = '^rp.*\.txt$';
epi_tmpl = '^swa.*\.nii$';

%counter is necessary because we might kick out subject 2 and then
%matlabbatch{2} would be empty, which will raise an error
matlabbatch = {};
counter = 0;

%outer loop: over subjects
for s = subs
    
    %increase the sub counter
    counter = counter + 1;
    
    %where do we find the data for subject s
    sub_dir = fullfile(fl_dir, sprintf('VP%d', s));
    
    %where do we want to write the SPM.mat
    out_dir = fullfile(sub_dir, 'firstlevel');
    create_if_necessary(out_dir);
    
    %this is the general information which doesn't depend on the run
    matlabbatch{counter}.spm.stats.fmri_spec.dir = {out_dir};
    matlabbatch{counter}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{counter}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{counter}.spm.stats.fmri_spec.timing.fmri_t = n_slices;
    matlabbatch{counter}.spm.stats.fmri_spec.timing.fmri_t0 = floor(n_slices / 2);
    matlabbatch{counter}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{counter}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{counter}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{counter}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{counter}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{counter}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{counter}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    %loop over runs, all the rest is dependent on which run we're in
    for r = runs
        
        %where are the epis and the rp file for this run
        run_dir = fullfile(sub_dir, sprintf('run%d', r));
        
        %collect the files
        epi_files = spm_select('ExtFPList', run_dir, epi_tmpl);
        
        %collect nuisance regressors
        rp_file = spm_select('FPList', run_dir, rp_tmpl);
        
        matlabbatch{counter}.spm.stats.fmri_spec.sess(r).scans = cellstr(epi_files);
        
        %load the onset file
        onset_file = fullfile(sub_dir, sprintf('run%d_onsets.mat', r));
        onsets = load(onset_file);
        onsets = onsets.(sprintf('run%d_onsets', r));
        
        %now we need to create our conditions for the specified run
        cond = [];
        cond_counter = 0;
        for w = 1:n_wm
            for v = 1:n_vis
                cond_counter = cond_counter + 1;
                name = sprintf('wm-%d_vis-%d', w, v);
                cond(cond_counter).name = name;
                cond(cond_counter).onset = onsets{cond_counter};
                cond(cond_counter).duration = duration;
                cond(cond_counter).tmod = 0;
                cond(cond_counter).pmod = struct('name', {}, 'param', {}, 'poly', {});
                cond(cond_counter).orth = 0;
            end
        end
        matlabbatch{counter}.spm.stats.fmri_spec.sess(r).cond = cond;
        
        %no multicond file, the conditions are specified above
        matlabbatch{counter}.spm.stats.fmri_spec.sess(r).multi = {''};
        matlabbatch{counter}.spm.stats.fmri_spec.sess(r).regress = struct('name', {}, 'val', {});
        matlabbatch{counter}.spm.stats.fmri_spec.sess(r).multi_reg = {rp_file};
        matlabbatch{counter}.spm.stats.fmri_spec.sess(r).hpf = 128;

    %end of the run loop,    
    end
%and end of the subject loop 
end

%run the design specification
spm_jobman('run', matlabbatch);

end