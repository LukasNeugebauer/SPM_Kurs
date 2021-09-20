function fl_contrast_definition
%We could take the betas to the secondlevel, but for more complicated
%contrasts, we usually define them on the first level and compute the
%secondlevel on the contrast images instead of the beta images
%In this script we're going to compute a few contrasts. The ones we are
%going to use in the secondlevel are contrasts in which we collapse the
%regressors over the sessions, i.e. only 1 and not 3 regressors for
%1-back/visibility 100%
% In addition we're going to compute a few contrasts for didactic purposes:
% * effect of interest (generic F-contrast containing all regressors of
%   interest
% * differential contrasts for 2-back vs. 1-back


%first, we define the contrast vectors
eff_of_int = repmat([eye(10), zeros(10, 6)], 1, 3);

%no need to define collapsing contrasts, they are the rows of the matrix
%above

%differential contrasts
two_lt_one = repmat([-ones(1, 5), ones(1, 5), zeros(1, 6)], 1, 3);
one_lt_two = - two_lt_one;

%path info
base_dir = get_base_dir;
fl_dir = base_dir.firstlevel;
s_info = get_study_info('firstlevel');
subs = s_info.subs;

%empty batch and counter for subjects
matlabbatch = {};
sub_counter = 0;

%loop over subjects
for s = subs
    
    %new subject -> increase counter
    %might seem absurd with only two subjects, but code discipline pays
    %off in the long run
    sub_counter = sub_counter + 1;
    
    %we're also going to count the contrasts
    con_counter = 0;
    
    %find the SPM.mat
    spmmat = fullfile(fl_dir, sprintf('VP%d', s), 'firstlevel', 'SPM.mat');
    
    %This is the general stuff that is not for a specific contrast
    matlabbatch{sub_counter}.spm.stats.con.spmmat = {spmmat};
    %Whether or not to delete the old contrasts. I usually do that because
    %I script all my contrasts and it gets confusing otherwise
    matlabbatch{sub_counter}.spm.stats.con.delete = 1;
    
    %eff of int
    con_counter = con_counter + 1;
    %is an f-contrast
    matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.fcon.name = 'eff_of_int';
    matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.fcon.weights = eff_of_int;
    matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.tcon.sessrep = 'none';
    
    %differential t-contrasts for n-back tasks
    con_counter = con_counter + 1;
    matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.tcon.name = '2back>1back';
    matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.tcon.weights = two_lt_one;
    matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.tcon.sessrep = 'none';
    
    con_counter = con_counter + 1;
    matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.tcon.name = '1back>2back';
    matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.tcon.weights = one_lt_two;
    matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.tcon.sessrep = 'none';
    
    %collapsing the regressors over sessions. remember, there are 2 levels
    %of working memory and 5 levels of visibility
    %these are the contrasts that we will be using in the secondlevel
    %analysis
    row_counter = 0;
    for wm = 1:2
        for vis = 1:5
            row_counter = row_counter + 1;
            con_counter = con_counter + 1;
            name = sprintf('wm-%d_vis-%d', wm, vis);
            vec = eff_of_int(row_counter, :);
            matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.tcon.name = name;
            matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.tcon.weights = vec;
            matlabbatch{sub_counter}.spm.stats.con.consess{con_counter}.tcon.sessrep = 'none';
        end 
    end
   
%end of subject loop
end

%run the batch
spm_jobman('run', matlabbatch);

end