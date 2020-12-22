clc
clear

%% Simplified EEG Simulation for Source Localization evaluation

%  ----- This code gives correct results -------  %

% This script is for EEG simulation originited from
% one/several numebr of sources in the brain mesh grid.
% Each source point is modeled as a dipole in a 3D space
% Thus, the activity of each source over time is [time x 3]
% mat. This source time course should be multiplied by the
% leadfield matrix which indicates if we have a 'unit'
% current source at locaiton r & time t, how would it
% project on each of the sensors on the scalp. This mat
% is of dimentions [3 x nChannels].
% By multiplying the dipole activity & leadfield matrix,
% we obtain the signal at sensor level which by adding a
% noise to it, we get a signal more similar to EEG.
% Source activity can be assumed to be a sin(t) with
% arbitrary frequency. (Simmilar to the ground-truth dataset
% in which they implanted an electrode inside the cortex
% and stimulated it with 0.5Hz, 1mV current.)

%% Loading the headmodel/leadfield/electrode locations

% I tested all these ingredients and they are fine so I am loading the
% saved versions instead of creating them again

mri = ft_read_mri('standard_mri.mat');
mri.coordsys = 'mni';
load('headmodel.mat');
load('leadfield.mat');
load('elec_aligned.mat');
elec = elec_aligned;

%% EEG simulation : 1 dopile

% create a dipole simulation with one dipole and a 10Hz sine wave
dip = [];
dip.pos = [-50 -10 30];
dip.mom = dip.pos/norm(dip.pos);


cfg = [];
cfg.headmodel   = headmodel;
cfg.elec        = elec_aligned; % Make sure to used the aligned one
cfg.dip.pos     = dip.pos;      %leadfield.pos([2319],:); % I chose these points manualy (ploted in last section)
cfg.dip.mom     = dip.mom;      %[10 0 0]';     % note, it should be transposed
cfg.dip.frequency = 10;
cfg.dip.amplitude = 1*70;
cfg.dip.unit    = 'cm';
cfg.ntrials     = 1;
cfg.triallength = 1;            % seconds
cfg.fsample     = 250;          % Hz
% cfg.relnoise    = 0.1;

raw1 = ft_dipolesimulation(cfg);

% plot simulated EEG for each channel
figure();
cfg.elecfile = elec_aligned;
layout = ft_prepare_layout(cfg,[]);
cfg = [];
cfg.layout = layout;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, raw1);

% plot the dipole inside the headmodel
figure();
style = {'edgecolor','none','facealpha',0.3,'facecolor','b'};
dip.pos_scaled = dip.pos;  % need to scaled as the headmodel units are in mm while the dip.pos are in cm
ft_plot_mesh(headmodel.bnd(1),style{:});
ft_plot_mesh(headmodel.bnd(2),style{:});
ft_plot_mesh(headmodel.bnd(3),style{:});
ft_plot_dipole(dip.pos_scaled(1,:), dip.mom(1,:),...
    'diameter',5,...
    'length', 10,...
    'color', 'red',...
    'unit', 'mm');

simEEG = raw1;
simEEG.data = raw1.trial{1,1};
simEEG.time = raw1.time{1,1};

% program smooth noise (Jim)
triallength = 1;
fsample     = 250;
fc          = 0.5;    % cutoff freq of low-pass filter -  (goes from 0 - 1 Hz)
% as fc increases, output sequence becomes more white with larger variance.
% As it decreases, output becomes smoother with lower power

[b,a]       = butter(3,fc);    	% b and a are coefficients of IIR digital Butterworth filter
% with filter order 3 in this case
l = triallength * fsample; % length of coloured noise sequence
w = randn(l,1);         % white noise input
y = filter(b,a,w);      % filter the input w using coefficients b and a
%y is output smooth noise vector
t = 1:l;
plot(t,w,'r', t,y,'b')

% adding a random noise to each channel of simulated EEG
for chan = 1:length(elec_aligned.label)
    w = randn(l,1);         % white noise input
    y = filter(b,a,w)/100000;
    simEEG.data(chan,:) = simEEG.data(chan,:) + y.';
end
% pop_eegplot(simEEG,1,1,1);% needs a specifc structure compatible with
% pop_eegplot form eeglab


%% Create FT data format for the simulated EEG
% Make fieldtrip data format for 2 conditions
data_all = [];
data_all.label      = cell(elec_aligned.label);
data_all.fsample    = 250;
data_all.trial{1,1} = simEEG.data;
data_all.time{1,1}  = simEEG.time;


%% Testing the software on this simulated data

cov = EEGsL.cov_calc(data_all);
sources = EEGsL.lcmv_beamformer(leadfield, headmodel, elec_aligned, cov);

EEGsL.plot_anatomical(sources, mri);

%% Automated testing of the location

[M,I] = max(sources.avg.pow);
max_Activity_pos = sources.pos(I,:);

loc_diff = dip.pos - max_Activity_pos*10;
if rms(loc_diff) < 1 % 1 cm is the resolution headmodel grid
    fprintf('the test has passed')
end

