function [name] = hostname
%function [name] = hostname
%
% Returns the name of the computer
% stolen from mathworks file exchange submission by Manuel Marin

[exit_code, name] = system('hostname');
if exit_code ~= 0
    if ispc
        name = getenv('COMPUTERNAME');
    else
        name = getenv('HOSTNAME');
    end
end
name = strtrim(lower(name));

end