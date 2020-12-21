function spec_param()

[srcdir,~,~] = fileparts(mfilename('fullpath'));

param_spec = [];
param_spec.EGGunit  = 'mv';
param_spec.EEGmin   = -600;
param_spec.EEGmax   = 600;
param_spec.fEEGmin  = 0.05;
param_spec.fEEGmax  = 100;

save(fullfile(srcdir,'param_spec.mat'),'-struct', 'param_spec');

end