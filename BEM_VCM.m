function [headmodel_BEM, sourcemodel, elec] = BEM_VCM(MRIpathname, channels)
    load([MRIpathname, 'MRI.mat'],'MRI')
    clfile = dir([MRIpathname 'c1*.nii']);
    iso_reg = clfile.name(3:end);
    
    %% create BEM headmodel
    % Segmented brain form load_mri
    segment = ft_read_mri([MRIpathname 'c1' iso_reg]);
    seg.gray = segment.anatomy;
    segment = ft_read_mri([MRIpathname 'c2' iso_reg]);
    seg.white = segment.anatomy;
    segment = ft_read_mri([MRIpathname 'c3' iso_reg]);
    seg.csf = segment.anatomy;
    segment = ft_read_mri([MRIpathname 'c4' iso_reg]);
    seg.skull = segment.anatomy;
    segment = ft_read_mri([MRIpathname 'c5' iso_reg]);
    seg.scalp = segment.anatomy;
    seg.coordsys = MRI.coordsys;
    seg.unit = MRI.unit;
    seg.dim = MRI.dim;
    seg.transform = MRI.transform;
    seg.anatomy = MRI.anatomy;
    
    cfg               = [];
    cfg.output        = {'brain','skull','scalp'};
    segmentedmri_BEM  = ft_volumesegment(cfg, seg);
    save ('segmentedmri_BEM.mat', 'segmentedmri_BEM', 'segment')
    
    % combination of brain, skull, scalp in orthogonal slices
    seg_i = ft_datatype_segmentation(segmentedmri_BEM,'segmentationstyle','indexed');
    cfg              = [];
    cfg.anaparameter = 'tissue';
    cfg.funparameter = 'seg';
    cfg.funcolormap  = gray(4); 
    cfg.location     = 'center';
    cfg.atlas        = seg_i;
%     ft_sourceplot(cfg, seg_i);
    
    %create mesh
    cfg             =[];
    cfg.spmversion  ='spm12';
    cfg.method      ='projectmesh'; 
    cfg.tissue      ={'brain','skull','scalp'};
    cfg.numvertices = [3000 2000 2000];
    mesh=ft_prepare_mesh(cfg,segmentedmri_BEM);
    %mesh=ft_convert_units(mesh,'m');
    
    %remove spike in scalp-mesh
%     ind_spike=find(mesh(3).pos(:,3)==-128.5);
%     mesh(3).pos(ind_spike,3)=-79.5;
    
%     %plot mesh of projectmesh
%     figure;
%     ft_plot_mesh(mesh(1))
%     figure;
%     ft_plot_mesh(mesh(2))
%     figure;
%     ft_plot_mesh(mesh(3))
%     
    %create BEM headmodel
    %create BEM headmodel
    oldFolder = cd('C:\Program Files\OpenMEEG\bin');
    cfg            = [];
    %cfg.conductivity = [0.3200 0.0045 0.3300]; % uncomment when checking for the inverse crime
    cfg.method     = 'openmeeg'; 
    cfg.spmversion = 'spm12';
    cfg.tissue     = {'brain' 'skull' 'scalp'};
    headmodel_BEM  = ft_prepare_headmodel(cfg, mesh);
    cd G:\MATLAB\Thomas
%     save('headmodel_BEM.mat', 'headmodel_BEM', '-v7.3')  
    
    % shorten channel name, make it a correct input for realignment
    channels_cor = cellfun(@(channels) channels(5:end-4),channels,'UniformOutput',false); 

    % read and align electrodes
    cfg = [];
    cfg.channel   = channels_cor;
    cfg.elec      = 'G:\MATLAB\fieldtrip-master\template\electrode\standard_1020.elc';
    cfg.method    = 'project'; 
    cfg.headshape = headmodel_BEM.bnd;
    elec = ft_electroderealign(cfg);
    %elec = ft_convert_units(elec,'m');
    
    % rename channels to the original names and change order for continuity
    elabel           = elec.label;
    elec.label       = cellfun(@(elabel) ['EEG ' elabel '-Ref1'],elabel,'UniformOutput',false);
    
    [~,index]        = ismember(channels, elec.label);
    indx2 = find(index==0);
    index(indx2)=[];
    elec.elecpos     = elec.elecpos(index,:);
    elec.chanpos     = elec.chanpos(index,:);
    elec.label       = elec.label(index);
    elec.cfg.channel = elec.label;
%     save('elec.mat', 'elec');

%     if isempty(index)
%         
%         % shorten channel name, make it a correct input for realignment
%         channels_cor = cellfun(@(channels) channels(5:end-4),channels,'UniformOutput',false); 
% 
%         % read and align electrodes
%         cfg = [];
%         cfg.channel   = channels_cor;
%         cfg.elec      = 'G:\MATLAB\fieldtrip-master\template\electrode\standard_1020.elc';
%         cfg.method    = 'project'; 
%         cfg.headshape = headmodel_BEM.bnd;
%         elec = ft_electroderealign(cfg);
%         %elec = ft_convert_units(elec,'m');
% 
%         % rename channels to the original names and change order for continuity
%         elabel           = elec.label;
%         elec.label       = cellfun(@(elabel) ['EEG ' elabel '-Ref'],elabel,'UniformOutput',false);
% 
%         [~,index]        = ismember(channels, elec.label);
%         indx2 = find(index==0);
%         index(indx2)=[];
%         elec.elecpos     = elec.elecpos(index,:);
%         elec.chanpos     = elec.chanpos(index,:);
%         elec.label       = elec.label(index);
%         elec.cfg.channel = elec.label;
%     end
    
	if isempty(index)

        % shorten channel name, make it a correct input for realignment
        channels_cor = cellfun(@(channels) channels(5:end-5),channels,'UniformOutput',false); 

        % read and align electrodes
        cfg = [];
        cfg.channel   = channels_cor;
        cfg.elec      = 'G:\MATLAB\fieldtrip-master\template\electrode\standard_1020.elc';
        cfg.method    = 'project'; 
        cfg.headshape = headmodel_BEM.bnd;
        elec = ft_electroderealign(cfg);
        %elec = ft_convert_units(elec,'m');

        % rename channels to the original names and change order for continuity
        elabel           = elec.label;
        elec.label       = cellfun(@(elabel) ['EEG ' elabel '-Ref1'],elabel,'UniformOutput',false);

        [~,index]        = ismember(channels, elec.label);
        indx2 = find(index==0);
        index(indx2)=[];
        elec.elecpos     = elec.elecpos(index,:);
        elec.chanpos     = elec.chanpos(index,:);
        elec.label       = elec.label(index);
        elec.cfg.channel = elec.label;
    end
    

  
    % create sourcemodel
    cfg             = [];
    cfg.resolution  = 7.5;
    cfg.tight       = 'yes';
    cfg.elec        = elec;
    cfg.inwardshift = 1;
    cfg.headmodel   = headmodel_BEM;
    sourcemodel = ft_prepare_sourcemodel(cfg);
%     save ('sourcemodel.mat','sourcemodel', 'mesh');
    
%     % plot sourcespace alone for better visualization
%     figure;
%     ft_plot_mesh(sourcemodel.pos(sourcemodel.inside,:))
%     hold on
%     ft_plot_mesh(mesh(1),'facecolor','skin','facealpha',0.5,'edgealpha',0.1)
%     
%     % plot headmodel with electrode positions and sourcespace
%     figure
%     ft_plot_mesh(headmodel_BEM.bnd(1), 'facecolor',[0.2 0.2 0.2], 'facealpha', 0.3, 'edgecolor', [1 1 1], 'edgealpha', 0.05);
%     hold on;
%     ft_plot_mesh(headmodel_BEM.bnd(2),'edgecolor','none','facealpha',0.4);
%     hold on;
%     ft_plot_mesh(headmodel_BEM.bnd(3),'facecolor','skin','facealpha',0.5,'edgealpha',0.1);
%     hold on;
%     ft_plot_sens(elec,'label','label', 'style', '.r');
%     hold on;
%     ft_plot_mesh(sourcemodel.pos(sourcemodel.inside,:))
    
end