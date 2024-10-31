function [cov, EEG_raw, channels] = EEG_preprocessing(file,Fs)

    hdr=ft_read_header(file);
    channels_temp=ft_channelselection('all',hdr);
    removechan = {'EEG A1-Ref1','EEG Oz-Ref1','EEG A2-Ref1','EEG Fpz-Ref1'};
    
    channels =[];
    ECG_chan = [];
    indg = zeros(numel(channels_temp),numel(removechan));
    k = 1;
    g = 1;
    for p = 1 : numel(channels_temp)
            for j = 1 : numel(removechan)
                indg(p,j) = strcmp(channels_temp{p},removechan{j});
            end
            
            if sum(indg(p,:))==0
                channels{k} = channels_temp{p};
                k = k + 1;
            elseif sum(indg(p,:))==1
                ECG_chan{g} = channels_temp{p};
                g = g + 1;
            end
    end
    indx = find(sum(indg'));
    
    cfg = [];
    cfg.channel = channels; % this is the default
    cfg.dataset = file; 
    EEG_raw = ft_preprocessing(cfg);
    
    cfg2 = [];
    cfg2.channel = ECG_chan;
    cfg2.dataset = file;
    ECG = ft_preprocessing(cfg2);
    
    % throw away an ICA component if it has a high correlation with the ECG
    % channel
    [trow_away, EEG_clean] = remove_ECG_gt(EEG_raw.trial{1}',Fs, ECG);

    EEG_notch = ft_preproc_dftfilter(EEG_clean', Fs);
    EEG_raw.trial{1} = EEG_notch;
 
    % covariance estimation
    cfg = [];
    cfg.keeptrials       = 'yes';
    cfg.covariance       = 'yes';
    cfg.covariancewindow = 'all'; 
    %cfg.removemean       = 'no'; % uncomment if EEG is time continuous
    cov = ft_timelockanalysis(cfg, EEG_raw);
end