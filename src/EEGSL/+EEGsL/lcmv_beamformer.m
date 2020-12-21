function sources = lcmv_beamformer(leadfield, headmodel, elec, cov)

cfg                 = [];
cfg.method          = 'lcmv';
% cfg.lcmv.kappa      = kappa;
cfg.lcmv.keepfilter = 'yes';
cfg.lcmv.fixedori   = 'yes';
cfg.lcmv.weightnorm = 'unitnoisegain';
cfg.senstype        = 'EEG'; % Remember this must be specified as either EEG, or MEG
cfg.elec            = elec;
cfg.headmodel       = headmodel;
cfg.sourcemodel     = leadfield;
sources = ft_sourceanalysis(cfg, cov);


end
