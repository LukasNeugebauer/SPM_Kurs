function create_if_necessary(folder)
%function create_if_necessary(folder)
%
%Create folder if it doesn't exist

if ~exist(folder, 'dir')
    mkdir(folder);
end

end