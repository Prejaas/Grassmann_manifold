function leadfield = create_leadfield(channels, sourcemodel, headmodel_BEM, elec, EEG_avg)

    % create leadfields
    cd 'G:\MATLAB\Thomas'
    oldFolder = cd('C:\Program Files\OpenMEEG\bin');
    cfg                    = [];
    cfg.channel            = channels;
    cfg.sourcemodel.pos    = sourcemodel.pos;
    cfg.sourcemodel.inside = sourcemodel.inside;
    cfg.sourcemodel.dim    = sourcemodel.dim;
    cfg.headmodel          = headmodel_BEM;
    cfg.elec               = elec;
    cfg.normalize          = 'yes';
    cfg.normalizeparam     = 0.5;
    leadfield = ft_prepare_leadfield(cfg,EEG_avg);
    cd 'G:\MATLAB\Thomas'
    
%     save('leadfield.mat', 'leadfield', '-v7.3')
     
end


