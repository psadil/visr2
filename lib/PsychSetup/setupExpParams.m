function expParams = setupExpParams( refreshRate, debugLevel, expt, stim, data )

%{
Parameters have been set during blocking. This function is mainly to grab
values that will be useful, or modify them based on debug level.

%}


%%
% expParams.instr_scrn_wait_dur_sec = 5;
% expParams.max_jitter_sec = 1;

%% Set general parameters that change based on debug level only
switch debugLevel
    case 0
        % Level 0: normal experiment
        expParams.iti = 1; % seconds to wait between each trial
        expParams.max_cfs_dur_sec = 30; % max duration until arrows are at full contrast
    case 1
        expParams.iti = .1; % seconds to wait between each trial
        expParams.max_cfs_dur_sec = 30; % max duration until arrows are at full contrast
end
%% Set parameters that change based on experiment (+ debuglevel)
switch expt
    case 'occularDominance'
        expParams.n_trial = max(data.trial);
        
    case {'visualRecollection'}
        expParams.noiseHertz = refreshRate/stim.mondrian_hz;
        
        expParams.n_trial = max(data.trial);
        expParams.n_list = max(data.list);
        expParams.n_study_rep = max(data.rep);
        
%         switch debugLevel
%             case 0
%                 expParams.max_cfs_dur_sec = 30;
%                 expParams.max_bino_dur_sec = 4;
%                 
%                 expParams.max_name_dur_sec = 30;
%                 expParams.max_noise_dur_sec = 4;
%                 expParams.ramp_dur_sec = 4;
%             case 1
%                 expParams.max_cfs_dur_sec = .3;
%                 expParams.max_bino_dur_sec = .3;
%                 
%                 expParams.max_name_dur_sec = 0.3;
%                 expParams.max_noise_dur_sec = 0.3;
%                 expParams.ramp_dur_sec = .1;
%         end
        
end



end