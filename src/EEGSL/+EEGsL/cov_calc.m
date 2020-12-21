function all_tlckw = cov_calc(eeg)

cfg = [];
cfg.covariance          = 'yes';
cfg.preproc.demean      = 'yes';
cfg.covariancewindow    = 'all';
cfg.keeptrials          = 'no';
cfg.removemean          = 'yes';

all_tlckw   = ft_timelockanalysis(cfg, eeg);

end