function realignment
%Realignment of the EPI images, i.e. we try to correct for movement
%This scripts uses the "Estimate & Reslice" version, but we tweak it so
%that we're not actually writing new files, only a mean EPI. The information
%about the reslicing gets stored in the header and applied the next time we 
%write a new image, which is going to be in the normalization step

%you know this stuff
base_dir = get_base_dir;
pp_dir = base_dir.preproc;

%collect all the files
%they have to be in a 1xn_runs Cell array, with every entry having all the
%scans for one session
n_runs = 3; 
scans = cell(1, n_runs);
%sprintf template for the directories
dir_tmpl = 'run%d';
%regex template for the files, the "a" prefix indicates that we're using
%the slice time corrected images
file_tmpl = '^arun.*\.nii';

for r = 1:n_runs
    direc = fullfile(pp_dir, sprintf(dir_tmpl, r));
    files = spm_select('ExtFPList', direc, file_tmpl);
    scans{r} = cellstr(files);
end

%create empty matlabbatch, then add scans
matlabbatch = {};
matlabbatch{1}.spm.spatial.realign.estwrite.data = scans;
%stick to the defaults here
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
%the following means only write the mean EPI, don't reslice ALL the EPIs
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

%run the batch
spm_jobman('run', matlabbatch);

end