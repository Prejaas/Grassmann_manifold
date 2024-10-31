addpath('G:\MATLAB\spm12')
addpath G:\MATLAB\fieldtrip-master
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% folder of the data
direc = 'C:\Data_Science\PAE_twente\good outcome sensor\';
cd(direc)
list = ls;
list(1:2,:)=[];
cd('G:\linux\matlab\Twente\Romesh')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get template MRI
MRIname     = 'mni_icbm152_t1_tal_nlin_sym_09c.nii';
MRIpathname = 'G:\MATLAB\Thomas\mni_icbm152_nlin_sym_09c\';
MRIFileName = [MRIpathname MRIname];
MRI=load_mri(MRIpathname, MRIFileName);
plot_mri(MRI,[])
warning off

%% get indices AAL atlas
[Gonglabels, ROI_indices] = select_ROIs_from_full_AAL;

%% some settings 
Fs = 256;
low_band  = [1 4 8 1];
high_band = [4 8 13 13]; 
mlag = round(Fs);
win_size = 10; % window width for PLI

%% init
FC = zeros(N,N,size(list,1),4);
PLI  = zeros(N,N,size(list,1),4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% source localisation   
close all
        
for d = 1:size(list,1)
    tic
    
    subj = char(list(d,:))
   
    name_new = char(strcat('C:\Data_Science\PAE_twente\good outcome source\','VE_',subj(1:end-4),'.mat'));
    if ~exist(name_new)
            
            % load header raw EEG data using code Twente
            name = strcat(direc,list(d,:));
     
            % get covariance matrix and get
            [cov, EEG_avg, channels] = EEG_preprocessing(name,Fs);
                          
            % create headmodel
            [headmodel_BEM, sourcemodel, elec] = BEM_VCM(MRIpathname, channels);

            % compute lead fields
            leadfield = create_leadfield(channels, sourcemodel, headmodel_BEM, elec, EEG_avg);

            % source localisation
            cov.avg = cov.trial;
            cov.avg = cov.avg(:,1:numel(elec.label),:);
            [eLORETA, interpolate] = LOR_BEM(channels, cov, MRI, leadfield, elec, headmodel_BEM,d);

            % get atlas
            aal = ft_read_atlas('G:\MATLAB\fieldtrip-master\template\atlas\aal\ROI_MNI_V4.nii');      
            cfg = [];
            cfg.parameter = 'tissue';
            cfg.downsample = 1; 
            cfg.interpmethod = 'linear'; 
            interp2 = ft_sourceinterpolate(cfg, aal, eLORETA);

            % get virtual electrodes
            cfg = [];
            cfg.pos = eLORETA.pos(eLORETA.inside,:);
            EEG_avg.grad = elec;
            data_vc = ft_virtualchannel(cfg, EEG_avg, eLORETA);
            VE_no_atlas = [];
            for no = 1: size(data_vc.trial,2)
                VE_no_atlas = cat(2,VE_no_atlas,data_vc.trial{no});
            end

            % use atlas to get mean VEs
            atlas_vec = reshape(interp2.tissue,size(interp2.inside,1)*size(interp2.inside,2)*size(interp2.inside,3),1);
            atlas_vec = atlas_vec(eLORETA.inside);
            VE_atlas = zeros(max(atlas_vec),size(VE_no_atlas,2));
            for p = 1 : max(atlas_vec)
                indx2 = find(round(atlas_vec)==p);
                VE_atlas(p,:) = mean(VE_no_atlas(indx2,:),1);
            end
            clear VE_no_atlas

            VE_atlas = VE_atlas(ROI_indices,:);
            VE_atlas_copy = VE_atlas;
            VE_atlas = [VE_atlas_copy(40:78,:); VE_atlas_copy(1:39,:)]; % flip again, because of ordering electrodes
            clear VE_atlas_copy
            
            name_new = char(strcat('C:\Data_Science\PAE_twente\good outcome source\','VE_',subj(1:end-4),'.mat'));
            save(name_new,'VE_atlas')
            cd G:\MATLAB\Grassman
            
       for frq = 1 : numel(low_freq)      
            % filter data
            VE_filt1 = nut_filter2(VE_atlas','firls','bp',100,low_band(frq),high_band(frq),Fs,1)';
            
            % compute irreversibility
            env_filt = abs(hilbert(VE_filt1'))';
            [FC(:,:,d,frq), f] = bivariate_grassman(env_filt,mlag,S);
    
            no_win = round(size(VE_filt1,2)/Fs./win_size);
            PLI_temp = zeros(N,N,no_win);
            beg = 1;
            eind = beg + win_size*Fs;
            for k = 1 : no_win-1
               PLI_temp(:,:,k) = phaselagindex(VE_filt1(:,beg:eind)');
                beg = beg + win_size*Fs;
                eind = eind + win_size*Fs;
            end
            PLI(:,:,sub,frq) = mean(PLI_temp,3);

        end
        fprintf('done for subj %d \n',d)

end
 