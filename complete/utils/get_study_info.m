function [s_info] = get_study_info(study)
%function [s_info] = get_study_info(study)
% study is either 'preproc' or 'rose'
%
%This function returns information about the studies from which the 
%preprocessing and first/secondlevel data comes from
%We use it because hardcoding is a bad idea and if we have to do it, then
%it's best to have it only in one place. If we change the TR, we only
%change it in ONE place, and the rest still runs

s_info = [];

switch study
    case 'rose'
        TR = 2.6;
        n_slices = 32;
        subs = [1, 2];
    case 'preproc'
        TR = 2.87;
        n_slices = 48;
        subs = 1;
    otherwise
        error('Unknown option. Try ''preproc'' or ''rose''.');
end

s_info.TR = TR;
s_info.n_slices = n_slices;
s_info.subs = subs;

end
