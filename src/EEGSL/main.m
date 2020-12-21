clc;
clear;

%% EEG Source Localization - main script
% Control module

param = EEGsL.params;
param.load_param('BCI4data.mat', 'BCI4channel.mat', 'icbm152_mri.mat' );

% [pxx,f] = pwelch(param.EEG.trial{1}(1,:), [100, 200], fs=100);

cov = EEGsL.cov_calc(param.EEG);

hm = EEGsL.headmodel(param.mri);

[aligned_elec, lf] = EEGsL.leadfield(hm, param.elec_loc, param.mri);

sources = EEGsL.lcmv_beamformer(lf, hm, aligned_elec, cov);

EEGsL.plot_anatomical(sources, param.mri);

EEGsL.output('lcmv_result.mat', sources, param.EEG, param.elec_loc);
