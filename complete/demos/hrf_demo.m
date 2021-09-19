%stolen from björn's script

irf  = zeros(1,500); % impulse response function (~s)
irf([10 150 350]) = 1;
hrf = spm_hrf(0.5); % 0.5 = TR
reg = conv(irf,hrf); % concolve onset vector and canonical HRF
figure;
subplot(3,1,1); plot(irf);
title('Stimulus onsets: Impulse response function');
subplot(3,1,2); plot(hrf);
title('Hemodynamic response function');
subplot(3,1,3); plot(reg);
title('Onset regressor: Hypothetical BOLD response');
