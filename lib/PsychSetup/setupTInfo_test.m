function tInfo = setupTInfo( expParams, expt, data )
%setupDebug setup values specific to debug levels

n_flips_total = expParams.n_flips_total;

tInfo = table;
tInfo.trial = repelem(1:expParams.nTrials, n_flips_total)';
tInfo.vbl = NaN(expParams.nTrials*n_flips_total,expParams.nStudyReps);
tInfo.missed = NaN(expParams.nTrials*n_flips_total,expParams.nStudyReps);

% tInfo.flip_in_trial = repmat(1:n_flips_per_trial, [expParams.nTrial,1]);

flip_type = repmat({[]}, [n_flips_total, 1]);
trial = 1;
for list = 1:expParams.nLists
    
    for rep = 1:expParams.nStudyReps
        for item = 1:expParams.nTrialsPerList
            flip_type(trial) = data(data.list == trial).tType_study(rep);
            trial = trial + 1;
        end
    end
    
    flip_type(trial:trial + expParams.nTrialsPerList) = repmat({'noise'}, [expParams.nTrialsPerList, 1]);
    trial = trial + expParams.nTrialsPerList;
end

%% 
tInfo.alpha = NaN([n_flips_total,1]);
switch expt
    case 'occularDominance'
        tInfo.type = repelem({'CFS'}, expParams.n_flips_cfs_block)';
    case {'practice', 'visualRecollection'}
        tInfo.type = repmat([repelem({'CFS'}, expParams.n_flips_cfs_block);
            repelem({'noise'}, expParams.n_flips_noise_block)], [expParams.nLists, 1] );
        
        for trial = 1:expParams.nTrials
            
            n_jitter_CFS = data(data.trial == trial).jitter_study;
            
            tInfo.alpha(tInfo.trial == trial && tInfo.type == 'CFS') = ...
                [zeros(1, n_jitter_CFS), ...
                0 : (1/expParams.mondrianHertz)/expParams.noiseFadeInDur : expParams.maxAlpha, ...
                ones(1, 1-n_jitter_CFS)]';
            
            n_jitter_noise = data(data.trial == trial).jitter_noise;
            
            tInfo.alpha(tInfo.trial == trial && tInfo.type == 'noise') = ...
                [zeros(1, n_jitter_noise), ...
                0 : (1/expParams.mondrianHertz)/expParams.noiseFadeInDur : expParams.maxAlpha, ...
                ones(1, 1-n_jitter_noise)]';
        end
end


end
