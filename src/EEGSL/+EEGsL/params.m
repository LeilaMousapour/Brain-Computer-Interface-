classdef params < handle
    % SUMMARY
    % params class is
    % The class is a "handle" class so that the methods be able to change
    % the properties
    properties
        % state variables
        EEG;
        elec_loc;
        mri;
        sl_cfg; % configuration of the source localization algorithm
    end
    
    methods
        function obj = params()
            % constructor
        end
        
        function load_param(obj, eegfname, elecfname, mrifname) %, cfgfname)
            
            assert(ischar(eegfname) & ischar(elecfname) & ischar(elecfname) ...
                , 'file name should be a string'); % throw an error
            
            fprintf('reading variable from file ''%s''\n', eegfname);
            obj.EEG = load(eegfname);
            fprintf('reading variable from file ''%s''\n', elecfname);
            obj.elec_loc = load(elecfname);
            fprintf('reading variable from file ''%s''\n', mrifname);
            obj.mri = load(mrifname);
            % obj.sl_cfg      = load(cfgfname);
            
            
            fprintf('---- verifying parameters');
            obj.verify_params();
            
            
        end
        
        function verify_params(obj)
            [srcdir,~,~] = fileparts(mfilename('fullpath'));
            param_spec_path = fullfile(srcdir, 'param_spec.mat');
            if ~exist(param_spec_path, 'file')
                EEGsL.spec_param(); % create the param_spec.mat as "parameter specification module"
            end
            param_spec = load(param_spec_path);
            
            % Verify the amplitude of the EEG signal
            % EEG is a {nTrial x nChann x nTimeSample } cell.
            N = length(obj.EEG.trial);
            minValue = zeros(1, N);
            maxValue = zeros(1, N);
            for i = 1:N
                maxValue(i) = max(max(obj.EEG.trial{i}));
                minValue(i) = min(min(obj.EEG.trial{i}));
            end
            
            assert(((max(maxValue) < param_spec.EEGmax) || (min(minValue) > param_spec.EEGmin)) ...
                , 'Amplitude of EEG signal not in normal range');
            
            
            % Verify the rank of the EEG matrix
            trail_rank = zeros(1, N);
            for i = 1:N
                trail_rank(i) = rank(obj.EEG.trial{i});
            end
            assert(min(trail_rank) == length(obj.EEG.label)...
                , 'EEG data is rank deficient');
            
            % Verify the freq renag of the EEG matrix
            
        end
        
    end
    
end


