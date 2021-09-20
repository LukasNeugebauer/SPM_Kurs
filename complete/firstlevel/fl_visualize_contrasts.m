%A small script to visualize a few example contrasts  that we could specify 
%on the first level
%There are two kinds of contrasts in SPM, F- and t-contrasts
%F-contrasts are undirected, t-contrasts are directed

clear;clc;

%It's a common practice to define an F-contrast for the effect of interest
%F-contrasts can be vectors or matrices
%The F-contrast for the eff_of_int would look like this if we would treat
%the same conditions between the sessions as differen
single_eff_of_int = [eye(10), zeros(10, 41);
                     zeros(10, 16), eye(10), zeros(10, 25);
                     zeros(10, 32), eye(10), zeros(10, 9)];
            
%SPM is padding zeros to the end, so we could ommit the last 9 columns,
%which are movement regressors for the last session and the session
%constants. The following is treated as the same by SPM
single_eff_of_int_no_pad = [eye(10), zeros(10, 32);
                     zeros(10, 16), eye(10), zeros(10, 16);
                     zeros(10, 32), eye(10)];
                 
%if we collapse conditions over sessions, which is conceptually closer to 
%the "real" effect of interest, it would look like this
eff_of_int = [eye(10), zeros(10, 6), eye(10), zeros(10, 6), eye(10), zeros(10, 9)];

%and again the zeros in the end can be truncated
eff_of_int_no_pad = [eye(10), zeros(10, 6), eye(10), zeros(10, 6), eye(10)];

%we can also use some MATLAB functionality to make this less typing
eff_of_int_lazy = repmat([eye(10), zeros(10, 6)], 1, 3);

%An example for a directed contrast would be to find areas that are more
%active for 2-back vs. 1-back tasks. remember, the first 5 regressors per
%session are the 1-back tasks, the second 5 are the 2-back tasks and we
%want the activity to be LARGER for 2-back tasks. so the directed contrast
%looks like this (in increasing levels of lazyness and decreasing levels of 
%potential for errors):
two_back_lt_one_back = [-1 -1 -1 -1 -1 1 1 1 1 1 0 0 0 0 0 0 -1 -1 -1 -1 -1 1 1 1 1 1 0 0 0 0 0 0 -1 -1 -1 -1 -1 1 1 1 1 1];
two_back_lt_one_back = repmat([-1 -1 -1 -1 -1 1 1 1 1 1 0 0 0 0 0 0], 1, 3);
two_back_lt_one_back = repmat([-ones(1, 5), ones(1, 5), zeros(1, 6)], 1, 3);

%And in the other direction we just need to flip the signs
one_back_lt_two_back = - two_back_lt_one_back;

%plot most of them
figure(28);
tiledlayout(3, 2);
nexttile;
imagesc(single_eff_of_int);
title('Session wise eff of int, padded');
nexttile;
imagesc(single_eff_of_int_no_pad);
title('Session wise eff of int, not padded');
nexttile;
imagesc(eff_of_int);
title('collapsed eff of int, padded');
nexttile;
imagesc(eff_of_int_no_pad);
title('collapsed eff of int, not padded');
nexttile;
bar(two_back_lt_one_back);
title('2-back larger than 1-back');
nexttile;
bar(one_back_lt_two_back);
title('1-back larger than 2-back');