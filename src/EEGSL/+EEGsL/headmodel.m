function headmodel = headmodel(mri)
% Head Model (BEM volume conduction model)

% MNI coordinates are taken from: Cutini S, Scatturin P, Zorzi M (2011): A
% new method based on ICBM152 head surface for probe placement in
% multichannel fNIRS

output_path = fullfile(cd);
headmodel_path = fullfile(output_path,'output','headmodel.mat');

if exist(headmodel_path, 'file') ~= 0
    fprintf('A headmodel already exist. Skip the headmodel calculation');
    headmodel = load(headmodel_path);
else
    
    % segment volume
    % Source: http://www.agricolab.de/template-headmodel-for-fieldtrip-eeg-source-reconstruction-based-on-icbm152/
    
    cfg = [];
    cfg.brainthreshold  = 0.5;
    cfg.scalpthreshold  = 0.22; % Was 0.15
    cfg.downsample      = 1;
    cfg.spmversion      ='spm12';
    cfg.output = {'brain','skull','scalp'};
    
    seg = ft_volumesegment(cfg, mri);
   
    
    % prepare mesh
    cfg = [];
    cfg.spmversion   ='spm12';
    cfg.method       = 'projectmesh';
    cfg.tissue       = {'brain','skull','scalp'};
    cfg.numvertices  = [1000, 1000, 1000];
    
    mesh = ft_prepare_mesh(cfg,seg);
    scaling = [0.999 1 1.001];
    for n_patch=1:length(scaling)
        mesh(n_patch).pos = mesh(n_patch).pos.*scaling(n_patch);
    end
    
    figure
    hold on
    ft_plot_mesh(mesh(1));
    ft_plot_mesh(mesh(2));
    ft_plot_mesh(mesh(3));
    alpha 0.1
    
    % prepare headmodel
    cfg = [];
    cfg.method      = 'dipoli';
    cfg.spmversion  = 'spm12';
    headmodel = ft_prepare_headmodel(cfg,mesh);
    headmodel = ft_convert_units(headmodel,'mm');
    

    % Plot the headmodel just in case!
    figure,
    ft_plot_mesh(headmodel.bnd(1), 'facecolor',[0.2 0.2 0.2], 'facealpha', 0.3,...
        'edgecolor', [1 1 1], 'edgealpha', 0.05);
    hold on;
    ft_plot_mesh(headmodel.bnd(2),'edgecolor','none','facealpha',0.4);
    hold on;
    ft_plot_mesh(headmodel.bnd(3),'edgecolor','none','facecolor',[0.4 0.6 0.4]);
    % plot fiducials,
    hold on
    style = 'or';
    
    save(headmodel_path, '-struct', 'headmodel');
end
end