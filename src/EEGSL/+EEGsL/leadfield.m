function [elec_aligned, leadfield] = leadfield(headmodel, elec, mri)

% Electrode allignment with template
% elec = ft_convert_units(elec, 'mm');

nas = mri.hdr.fiducial.mri.nas;
lpa = mri.hdr.fiducial.mri.lpa;
rpa = mri.hdr.fiducial.mri.rpa;
    
transm = mri.transform;

nas = ft_warp_apply(transm,nas, 'homogenous');
lpa = ft_warp_apply(transm,lpa, 'homogenous');
rpa = ft_warp_apply(transm,rpa, 'homogenous');

% plot pre allignment
figure;
% head surface (scalp)
ft_plot_mesh(headmodel.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]);
hold on;
% electrodes
ft_plot_sens(elec, 'marker', 'o', 'color', 'black');
title('electrode location relative to headmodel BEFORE alignmnet');

% create a structure similar to a template set of electrodes to allign
% MRI with fiducials (first pass)
fid = [];
fid.elecpos       = [nas; lpa; rpa];       % ctf-coordinates of fiducials
fid.chanpos       = [nas; lpa; rpa];       % ctf-coordinates of fiducials
fid.label         = {'NZ','LPA','RPA'};    % same labels as in elec
fid.unit          = 'mm';                  % same units as mri

% Automatic alignment based on fiducials
cfg = [];
cfg.headshape     = headmodel.bnd(1);
cfg.method        = 'project';    %  was 'fiducial', 'project seems to be best'
cfg.target        = fid;                   % see above
cfg.template      = fid;                   % see above
cfg.elec          = elec;
cfg.fiducial      = {'NZ', 'LPA', 'RPA'};  % labels of fiducials in fid and in elec
elec_aligned      = ft_electroderealign(cfg);

% plot post allignment
figure;
ft_plot_sens(elec_aligned,'marker', 's', 'color', 'black');
hold on;
ft_plot_mesh(headmodel.bnd(1),'facealpha', 0.85, 'edgecolor', 'none', 'facecolor', [0.65 0.65 0.65]); %scalp

title('electrode location relative to headmodel AFTER alignmnet');

%% Compute lead field matrix (Forward model)

% here we discritize the brain into a grid and for each grid point the lead
% field matrix is calculated

cfg = [];
cfg.headmodel       = headmodel;
cfg.resolution      = 1;
cfg.normalize       = 'yes';
cfg.grid.tight      = 'yes';
cfg.grid.resolution = 1;
cfg.grid.unit       = 'cm'; % use a 3-D grid with a 1 cm resolutionccfg.elec            = elec_aligned;
cfg.elec            = elec_aligned; % structure with electrode positions or filename, see FT_READ_SENS
% cfg.grad     = % structure with gradiometer definition or filename, see FT_READ_SENS
% cfg.opto     = % structure with optode definition or filename, see FT_READ_SENS
% cfg.layout   = % structure with layout definition or filename, see FT_PREPARE_LAYOUT
% cfg.senstype = % string, can be 'meg', 'eeg', or 'nirs', this is used to  
%                % choose in combined data (default = 'eeg')
leadfield = ft_prepare_leadfield(cfg);

% Plot the lead field
figure();
plot3(leadfield.pos(leadfield.inside,1), leadfield.pos(leadfield.inside,2), ...
    leadfield.pos(leadfield.inside,3), 'k.');
hold on;
title('Leadfield');

end