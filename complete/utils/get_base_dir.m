function [base_dir] = get_base_dir
%function [base_dir] = get_base_dir
%
%return path information for data depending on the computer you're on
%you need to adapt this script before using it

name = hostname;
base_dir = [];

%just change this to the name of your computer
%my computer is named 'manjaro', so I'll check for that
if strcmp(name, 'manjaro')
    %change this to the folder to which you downloaded the spm kurs data
    base_dir.base = '/home/media/spm_kurs_data';
    base_dir.preproc = fullfile(base_dir.base, 'PreProcessing');
    base_dir.firstlevel = fullfile(base_dir.base, 'First_Level');
    base_dir.secondlevel = fullfile(base_dir.base, 'Second_Level');
else
    error('%s not yet implemented as host', name);
end

end