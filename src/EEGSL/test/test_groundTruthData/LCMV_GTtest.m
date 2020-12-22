clc;
clear;

%% Testing the ground truth data set for Source Localization evaluation
%  ----- This code gives correct results -------  %

% Please change the data file name (line 42) and the corresponding actual
% location of the electrode (line 127) for appropriate results

%% Load EEG Head Model (BEM volume conduction model)

load EEGheadmodel
mri = load('mri');
mri = mri.mri;

%% Creating the Electrode location file compatible with Fieldtrip format
% as the location file for the ground truth dataset is in a specific
% format, we need to use the 'physionet_channels.sfp' as they have used the
% physionet configuration for data recording. minor chages are required

channels = load('sub01taskseegstimelectrodes.mat');
channels =  channels.sub01taskseegstimelectrodes;

chan_locs = ('physionet_channels.sfp');
elec = ft_read_sens(chan_locs, 'senstype', 'eeg');


elec.label = cellstr(channels(:,1));
elec.chanpos = double(channels(:,[2:4]));
elec.elecpos = elec.chanpos;
elec.chantype = [elec.chantype;elec.chantype;elec.chantype;elec.chantype];
elec.chanunit = [elec.chanunit;elec.chanunit;elec.chanunit;elec.chanunit];
elec.unit = 'm';

elec = ft_convert_units(elec, 'mm');

%% Reading in the data 
% Subject05 - run01 - channel G'8	
% 0.5Hz, 1mA

% Set the name of the file for the subject of 
df = load('sub-02_task-seegstim_run-01_epochs.mat', 'array');%******** change sbj
df = df.array;

data = {};
for i = 1:size(df, 1)
    data{i}  = squeeze((df(i,:,:)));
end


% Make fieldtrip data format for 2 conditions
data_all = [];                        
data_all.label    = cellstr(channels(:,1));
data_all.fsample  = 8000;
data_all.trial = data.';

time = {};
for n_trial = 1:size(data, 2)
    time{n_trial} = (1:size(data{n_trial},2))./data_all.fsample; 
end
data_all.time  = time.';


%% Testing the software
% we use a saved headmodel as it takes a long time to generate

cov = EEGsL.cov_calc(data_all);

[aligned_elec, lf] = EEGsL.leadfield(headmodel, elec, mri);

sourceAll = EEGsL.lcmv_beamformer(lf, headmodel, aligned_elec, cov);

% EEGsL.plot_anatomical(sources, mri); % as I need values from inside this
% funtion and I don't want to change the code of this module, I just use
% the implementation of the plot function below:

%% The actual locations of the implanted electrodes 
% These locations are obtained from the dataset
% The order is as bellow:
%   sbj1 - K13
%   sbj2 - X'1
%   sbj3 - B'13
%   sbj4 - O1
%   sbj5 - G'8
%   sbj6 - E'2
%   sbj7 - B11

actual_locs = [0.04562, -0.01771, 0.05281;
    -0.02965, 0.01891, 0.00335;
    -0.06485, -0.01497, -0.01635;
    0.00245, -0.0788, 0.01541;
    -0.04028, 0.05171, 0.01671;
    -0.0193, -0.05521, -0.00769;
    0.05279, -0.0047, -0.02791] * 1000; % m to mm

%% Compute the distance of the maximum activity in the result with the actual location

% locate the time where the spike happens
[M,I] = max(max(data_all.trial{1,1}))

% extract the amplitude of the sources at that specific time point when the
% spike happens
maxActivity = [];
for n_sources = 1:size(lf.pos, 1)
    if isempty(sourceAll.avg.mom{n_sources})
        maxActivity= [maxActivity NaN];
    else
    maxActivity= [maxActivity sourceAll.avg.mom{n_sources}(I)];
    end
end
sourceAll.avg.maxActivity = maxActivity.';

% locate the source point with the maximum activity
% for this, we first need to transfer the location of the source points to
% the mni coordinate system using the mei and ft_sourceinterpolate()
% function
cfg = [];
cfg.downsample	= 10;
cfg.parameter	= 'maxActivity';
sourceInt_nocon_all = ft_sourceinterpolate(cfg, sourceAll , mri);

% get the location of the maximum activity
[M,I] = max(sourceInt_nocon_all.maxActivity);
max_Activity_pos = sourceInt_nocon_all.pos(I,:);
dip.mom = max_Activity_pos/norm(max_Activity_pos);

actual_loc = actual_locs(2,:); % ****************change to sbj on interest
actual_dip.mom = actual_loc/norm(actual_loc);

% plot the actual and located dipoles inside the headmodel
figure();
style = {'edgecolor','none','facealpha',0.3,'facecolor','b'};
ft_plot_mesh(headmodel.bnd(1),style{:});
ft_plot_mesh(headmodel.bnd(2),style{:});
ft_plot_mesh(headmodel.bnd(3),style{:});
ft_plot_dipole(actual_loc(1,:), actual_dip.mom(1,:),...
    'diameter',5,...
    'length', 10,...
    'color', 'red',...
    'unit', 'mm');
ft_plot_dipole(max_Activity_pos(1,:), dip.mom(1,:),...
    'diameter',5,...
    'length', 10,...
    'color', 'black',...
    'unit', 'mm');


%% Plotting the result on the mri

% interpolate sources inorder to align the measure of power increase with
% the structural MRI. This alignment is done according to the anatomical
% landmarks (nasion, left and right ear)

mri = ft_volumereslice([], mri);
cfg = [];
cfg.downsample	= 2;
cfg.parameter	= 'maxActivity';
sourceInt_nocon_all = ft_sourceinterpolate(cfg, sourceAll , mri);

cfg = [];
cfg.method       = 'slice';
cfg.funparameter = 'maxActivity';
ft_sourceplot(cfg,sourceInt_nocon_all);
title('Subj05 - Source activity at the moment of puls - LCMV')


%% Automated testing of the location

% I have chosen the threshold to 30 mm due to the paper as their
% results would typically have 2~20mm error
loc_diff = max_Activity_pos - actual_loc;
if norm(loc_diff) < 30 
    fprintf('the test has passed')
end

%% Results
% sbj1: 15.3972
% sbj2: 81.3316
% sbj3: 37.9282
% sbj4: 53.9885
% sbj5: 18.4899
% sbj6: 42.1061
% sbj7: 66.3039
