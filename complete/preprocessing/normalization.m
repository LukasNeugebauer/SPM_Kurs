%Normalize T1 image and EPIs, i.e. morph them into the space of the
%standard brain as defined by the MNI template
%
%This is so that group analysis make sense because otherwise you might
%average one subjects hippocampus with another ones fusiform gyrus
%(you actually still might do that)

%the first tricky MATLAB bit, we want to find the tissue probability maps
%without actually hardcoding where they are
%if we know where SPM is:
spm_dir = fileparts(which('spm'));
%then we know where the TPMs are:
tpm_dir = fullfile(spm_dir, 'tpm');

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
%regex template for the EPI files
epi_tmpl = '^arun.*\.nii';
%regex template for the T1 files
t1_tmpl = '^s.*\.nii';
t1_dir = fullfile(pp_dir, 'T1');

%collect T1 image
%we can do the "putting into a cell" bit on the same line
t1 = {spm_select('FPList', t1_dir, t1_tmpl)};

%collect epis
epis = cell(1, 3);
for r = 1:n_runs
    direc = fullfile(pp_dir, sprintf(dir_tmpl, r));
    files = spm_select('ExtFPList', direc, file_tmpl);
    epis{r} = cellstr(files);
end

%this is a bit tricky, we need to combine all of them in one cell array
%cat is short for concatenate, cat(1, bla, blub) means concatenate bla and
%blub along the first dimension
%epis{:} returns the subcells as single variabels
%so it's the same as epis{1}, epis{2}, epis{3}
all_files = cat(1, t1, epis{:});

matlabbatch = {};
%this is the file we use to calculate the warp field
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = t1;
%These are all files we wish to reslice in the standardized space
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = all_files;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {fullfile(tpm_dir, 'TPM.nii')};
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
                                                             78 76 85];
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';

spm_jobman('run', matlabbatch);