function [LOR, interpolate,fig]=LOR_BEM(channels, cov, MRI, leadfield, elec, headmodel_BEM,sub)
 
%inverse solution
cfg                        = [];
cfg.method                 = 'eloreta';                    %specify method
cfg.sourcemodel            = leadfield;                %the precomputed leadfield
cfg.headmodel              = headmodel_BEM;            %the head model
cfg.elec                   = elec;                     %electrode positions
cfg.channel                = channels;
% cfg.lcmv.fixedori          = 'yes';
% cfg.lcmv.weightnorm             =  'unitnoisegain';
% cfg.lcmv.normalize              = 'on';
% cfg.lcmv.normalizeparam         = 1;
% % cfg.lcmv.keepfilter              ='yes';
% cfg.lcmv.projectnoise           = 'yes';
% cfg.lcmv.kappa               = 0.1;  

cfg.eloreta.lambda         = 0.05;
cfg.eloreta.prewhiten      = 'yes';
cfg.eloreta.scalesourcecov = 'yes';
cfg.eloreta.keepfilter              ='yes';
cfg.eloreta.normalize              = 'on';
cfg.eloreta.lcmv.normalizeparam         = 0.5;

LOR                    = ft_sourceanalysis(cfg,cov);

%plot power of the source
cfg              = [];
cfg.parameter    = 'pow';
cfg.interpmethod = 'linear';
interpolate      = ft_sourceinterpolate(cfg, LOR , MRI);

cfg = [];
cfg.method        = 'ortho';
%cfg.method        = 'slice';
%cfg.method        = 'glassbrain';
cfg.funparameter  = 'pow';
ft_sourceplot(cfg,interpolate);
title(num2str(sub))
end