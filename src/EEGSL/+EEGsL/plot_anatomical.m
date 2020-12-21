function plot_anatomical(sources, mri)

mri = ft_volumereslice([], mri);

cfg = [];
cfg.downsample	= 1;
cfg.parameter	= 'pow';
sourceInt_nocon = ft_sourceinterpolate(cfg, sources , mri);

% Plot the interpolated data
cfg = [];
cfg.method       = 'slice';
cfg.funparameter = 'pow';
% cfg.maskparameter = 'mask';
% sourceInt_nocon_all.mask = sourceInt_nocon_all.pow > max(sourceInt_nocon_all.pow(:))*0.65;
ft_sourceplot(cfg,sourceInt_nocon);
title('source power')

end