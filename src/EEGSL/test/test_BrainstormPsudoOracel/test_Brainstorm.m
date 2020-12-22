clc;
clear;
%% Test
% this script takes BCI competion data for subject b and first, segment it
% into trials (as the data is continuos) bsed on the dataset description.
% Finaly, the output of the software for the average of all right and left
% trials will be calculated and plotted. The source power plots will be
% compared with the output plots of Brainstorm on the same data frames.

%% read BCI competition dataset
rawdf = load('BCICIV_calib_ds1b.mat'); % Sbj b: left/right
rawdf.cnt= 0.1*double(rawdf.cnt); % to convert into uV based on the description

% Separeting Yes/No trials
df =[];
df.EEG = {}; 

trial_len = rawdf.mrk.pos(2)-rawdf.mrk.pos(1); 
FixCrsdur = 200;
Intv = 400;
% Total trail lengtht = 8s
% 1- Fixation cross = 2s
% 2- Visual cue = 4s
% 3- Interleaved = 2s

for n_trial = 1:size(rawdf.mrk.y,2)
    df.EEG{n_trial,1} = ...
    double(rawdf.cnt(rawdf.mrk.pos(n_trial): rawdf.mrk.pos(n_trial)+Intv, :).' );
    df.lable(n_trial) = rawdf.mrk.y(n_trial); 
end

% Make fieldtrip data format
% Channel labels are changed -> CFC->FCC/CFC7->FFT7/CFC8->FTT8/CCP7->TTP7/CCP8->TTP8
rawdf.label =  {'AF3';'AF4';'F5';'F3';'F1';'Fz';...
    'F2';'F4';'F6';'FC5';'FC3';'FC1';'FCz';'FC2';...
    'FC4';'FC6';'FFT7';'FCC5';'FCC3';'FCC1';'FCC2';...
    'FCC4';'FCC6';'FTT8';'T7';'C5';'C3';'C1';'Cz';...
    'C2';'C4';'C6';'T8';'TTP7';'CCP5';'CCP3';'CCP1';...
    'CCP2';'CCP4';'CCP6';'TTP8';'CP5';'CP3';'CP1';...
    'CPz';'CP2';'CP4';'CP6';'P5';'P3';'P1';'Pz';...
    'P2';'P4';'P6';'PO1';'PO2';'O1';'O2'};

% Data right = -1
data_right = [];                           
data_right.label      = rawdf.label;  
data_right.fsample    = rawdf.nfo.fs;      
data_right.trial      = df.EEG(df.lable ~= 1);   

time = {};
for n_trial = 1:size(data_right.trial , 1)
    time{n_trial} = (1:Intv+1)./data_right.fsample; 
end
data_right.time       = time.';     

% Data left = 1
data_left = [];
data_left.label      = rawdf.label; 
data_left.fsample    = rawdf.nfo.fs; 
data_left.trial      = df.EEG(df.lable == 1);   

time = {};
for n_trial = 1:size(data_left.trial , 1)
    time{n_trial} = (1:Intv+1)./data_right.fsample; 
end
data_left.time       = time.';

save('BCIiv_dataright', '-struct', 'data_right');
save('BCIiv_dataleft', '-struct', 'data_left');

%% EEG Source Localization - right hand data

param = EEGsL.params;
param.load_param('BCIiv_dataright.mat', 'BCI4channel.mat', 'icbm152_mri.mat' );

cov = EEGsL.cov_calc(param.EEG);

hm = EEGsL.headmodel(param.mri);

[aligned_elec, lf] = EEGsL.leadfield(hm, param.elec_loc, param.mri);

sources_right = EEGsL.lcmv_beamformer(lf, hm, aligned_elec, cov);

EEGsL.plot_anatomical(sources_right, param.mri);

% EEGsL.output('lcmv_result.mat', sources, param.EEG, param.elec_loc);

%% EEG Source Localization - left hand data

param = EEGsL.params;
param.load_param('BCIiv_dataleft.mat', 'BCI4channel.mat', 'icbm152_mri.mat' );

cov = EEGsL.cov_calc(param.EEG);

hm = EEGsL.headmodel(param.mri);

[aligned_elec, lf] = EEGsL.leadfield(hm, param.elec_loc, param.mri);

sources = EEGsL.lcmv_beamformer(lf, hm, aligned_elec, cov);

EEGsL.plot_anatomical(sources, param.mri);
