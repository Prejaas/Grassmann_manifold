function [trow_away, clean_EEG] = remove_ECG_gt(EEG,Fs,ECG)
% remove ECG artefact
% addpath(genpath('G:\linux\matlab\Twente\fooof_mat-main'))
addpath(genpath('G:\linux\matlab\ICA_tools'))

%% start with temporal ICA
% remove first minute of data

[ica, A, ~] = fastica(EEG','approach','symm','epsilon',0.008,'g','tanh' );
% [ica, A, ~] = fastica(EEG','approach','symm','maxNumIterations',200);

mat = corr(ica',ECG.trial{1}');
ecg_prob = max(abs(mat'))>0.6;


if sum(ecg_prob) ~= 0 
    ind_ecg = find(ecg_prob ==1);
    A(:,ind_ecg) = 0;
    trow_away = ind_ecg;
    clean_EEG = A * ica;
    clean_EEG = transpose(clean_EEG);
    disp(['we throw away' num2str((trow_away))])
else
    clean_EEG = EEG; 
% 	ind_ecg = find(ecg_prob ==1);
    trow_away = [];
    disp(['we throw away nothing'])

end

plots = 0;
if plots ==1

      figure
            for m = 1:size(ica,1)
                subplot(2,ceil(size(ica,1)/2),m)
                plot(ica(m,:))
                title(num2str(m))
                xlim([1 Fs*5 ])
             	set(gcf, 'Position',  [50, 50, 1300, 800])

            end
            
            figure
            for m = 1:size(ica,1)
                subplot(2,ceil(size(ica,1)/2),m)
                [freq, psd] = freqplot(ica(m,:)',Fs);
                y = smooth(log(psd),20);
                plot(freq,y)
                title(num2str(m))
                xlim([0 70])
             	set(gcf, 'Position',  [300, 100, 1300, 800])

            end
            
end