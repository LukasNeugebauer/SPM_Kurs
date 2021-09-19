function dicom_import
%Import DICOM images inplace
%Since we won't need them again, we're going to delete them afterwards and
%only keep the niftis
%This is the complete version, if you're participating in the course, move
%to the interactive version and complete it

%because not everyone has the same folder structure, collect that
%information
base_dir = get_base_dir;
pp_dir = base_dir.preproc;

%there are 4 directories that we want to do the exact same thing in, so
%we're going to loop over them
direcs = {'T1', 'run1', 'run2', 'run3'};
n_direcs = length(direcs); %avoid hardcoding if possible
%if you add or remove a directory, the code is still going to run

%of course we need to now which images to convert. Those happen to be all
%files starting with 'MR'. We're going to specify that using a "regular 
%expression" and since we are going to reuse it for the EPI images, why not 
%store it in a variable?
%^ means start of string, $ means end of string. Without the ^ we would
%also match all something like 'thisisnotactuallyaMRimage.nii'
%So this means all files that start with MR and we don't care what's after that
file_tmpl = '^MR.*$';

%we create the matlabbatch as an empty cell and start counting from 0
%the idea behind using a counting variable is that you can loop over stuff 
%and it's going to keep up at the right pace and if you delete or add
%parts of the code, your indeces are still going to be valid
matlabbatch = {};
counter = 0;

%loop over the directories
for d = 1:n_direcs
    
    %what is the absolute path to the directory from which we want to
    %import DICOMs?
    %fullfile just adds the correct file separator ('/' or '\', depending 
    %on the operating system)
    dicom_dir = fullfile(pp_dir, direcs{d}); %{} is how you index a cell

    %Now use a SPM function to actually find the files
    %spm_select is pretty flexible, we'll revisit again quite a few times
    dicoms = spm_select('FPList', dicom_dir, file_tmpl);
    %Ironically, SPM doesn't accept its own output as input, so we're going 
    %to put it into a cellstr. In general SPM is very picky about the data
    %type of input and often when something doesn't run, it's because you
    %didn't pass a cell or cellstr (which are the same thing really...)
    dicoms = cellstr(dicoms);

    %this is what a module from the batch editor looks like in code
    %Every time we add a new module to the batch, we increase the counter
    counter = counter + 1;
    matlabbatch{counter}.spm.util.import.dicom.data = dicoms;
    matlabbatch{counter}.spm.util.import.dicom.root = 'flat';
    matlabbatch{counter}.spm.util.import.dicom.outdir = {dicom_dir}; %store them in the same directory
    matlabbatch{counter}.spm.util.import.dicom.protfilter = '.*';
    matlabbatch{counter}.spm.util.import.dicom.convopts.format = 'nii';
    matlabbatch{counter}.spm.util.import.dicom.convopts.meta = 0;
    matlabbatch{counter}.spm.util.import.dicom.convopts.icedims = 0;

    %because we don't need them again, we're going to keep it tidy and save
    %space and delete the DICOM images. Doesn't have to be done in SPM, but
    %might as well
    %new module -> increase counter
    counter = counter + 1;
    %the files didn't change
    matlabbatch{counter}.cfg_basicio.file_dir.file_ops.file_move.files = dicoms;
    matlabbatch{counter}.cfg_basicio.file_dir.file_ops.file_move.action.delete = false;
   
%and that's it. now MATLAB is going to jump back to the "for", increase "d"
%by 1 and repeat the same stuff for the other directories
end

%Now we have all the stuff we wanted stored as a recipe for SPM in our
%matlabbatch variable, so we just need to tell SPM to actually run the
%batch
%this is the equivalent of hitting the green arrow in the batch editor 
spm_jobman('run', matlabbatch)
end