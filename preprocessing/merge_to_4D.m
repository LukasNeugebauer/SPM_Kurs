function merge_to_4D
%We could just go on with the single niftis, i.e. one file per volume. But
%that's going to be very tedious, so instead we're going to merge them
%together to a single 4D nifti where the first three dimensions are space
%and the fourth is time
%
%to be sure that we have stable images, we're going to delete a few dummy
%scans by just not including them in the 4D nifti

%to get the correct number, you need to know the TR and how many scans the
%scanner already discards. Talk to the MTA or the MR physicist, if you have
%one!
N_DUMMY = 3; %how many dummies do we want to get rid off?

%you already know this
%because not everyone has the same folder structure, collect that
%information
base_dir = get_base_dir;
pp_dir = base_dir.preproc;

%the T1 image is already merged automatically when converting to nifti, 
%because it's just a single volume.
%The functional scans need to be merged: we're again going to loop over
%them
direcs = {'run1', 'run2', 'run3'};
n_direcs = length(direcs);

%empty matlabbatch and counter
matlabbatch = {};
counter = 0;

%all the niftis start with 'f' and end with '.nii'
%we need to 'escape' the '.', because in regular expressions a '.' means any
%character
file_tmpl = '^f.*\.nii';

%template for the name of the 4d nifti. for the "%d" part, we'll include
%the number of the run during the loop
out_tmpl = 'run-%d.nii';

%Loop over the directories
for d = 1:n_direcs
   
    %define folder for run d and collect files
    nifti_dir = fullfile(pp_dir, direcs{d});
    niftis = spm_select('FPList', nifti_dir, file_tmpl);
    niftis = cellstr(niftis);
    
    %remember to kick out some dummies
    keep_niftis = niftis(N_DUMMY + 1:end);
    
    %specify the output file
    outfile_name = sprintf('run-%d.nii', d);
    
    %new module, increase counter
    counter = counter + 1;
    matlabbatch{counter}.spm.util.cat.vols = keep_niftis;
    matlabbatch{counter}.spm.util.cat.name = outfile_name; 
    matlabbatch{counter}.spm.util.cat.dtype = 4;
    matlabbatch{counter}.spm.util.cat.RT = NaN;

    %delete the 3D volumes INCLUDING the dummies
    counter = counter + 1;
    matlabbatch{counter}.cfg_basicio.file_dir.file_ops.file_move.files = niftis;
    matlabbatch{counter}.cfg_basicio.file_dir.file_ops.file_move.action.delete = false;

%end of the loop, MATLAB will repeat this for all the runs
end

%and we just need to run the whole matlabbatch once it's defined
spm_jobman('run', matlabbatch);
end