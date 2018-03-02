function main(varargin)

warning('off','MATLAB:nargchk:deprecated');
%% collect input
% use the inputParser class to deal with arguments
ip = inputParser;
addParameter(ip, 'subject', 0, @isnumeric);
addParameter(ip, 'dominantEye', 'right', @(x) sum(strcmp(x, {'left','right'}))==1);
addParameter(ip, 'debugLevel', 0, @(x) isnumeric(x) && x >= 0);
addParameter(ip, 'responder', 'user', @(x) sum(strcmp(x, {'user','simpleKeypressRobot'}))==1);
addParameter(ip, 'experiments', [1,1], @(x) length(x)==2);
addParameter(ip, 'study', 1, @(x) isnumeric(x));
addParameter(ip, 'refreshRate', 100, @(x) any(x==[100,60]));
addParameter(ip, 'stereomode', 1, @(x) any(x==[0,1]));
addParameter(ip, 'window_rect', [], @(x) length(x)==4); % [0, 0, 1920, 600]
addParameter(ip, 'SkipSyncTests', 2, @(x) any(x==[0,1,2]));
addParameter(ip, 'experiment', 'visual_recall2', @ischar);
parse(ip,varargin{:});
input = ip.Results;


%% setup
[constants, input, exit_stat] = setupConstants(input, ip);
if exit_stat == 1
    windowCleanup(constants);
    return
end

% if strcmp(input.responder,'user') && input.debugLevel == 0
%     demographics(constants.subDir);
% end

try
    PsychDefaultSetup(2);
    ListenChar(-1);
    HideCursor;
    
    responseHandler = makeInputHandlerFcn(input.responder);
    window = setupWindow(constants, input);

    [stim, window] = setupStim(window);
        
    if input.experiments(1)
        %% assess occular dominance
        expt = 'occularDominance';
        [data, tInfo, expParams, input] = runOccularDominance(input, constants, window, responseHandler, stim, expt);
        domEye = checkOccularDominanceData(data);
        % save data
        structureCleanup(expt, input.subject, data, tInfo, constants, expParams, input, window, stim);
    else
        domEye = input.dominantEye;
    end
        
    %% run main experiment
    if input.experiments(2)
        expt = 'visualRecollection';
        [data, tInfo, expParams, input] =...
            runCFSgonogo(input, constants, window, responseHandler, stim, domEye, expt);
        % save data
        structureCleanup(expt, input.subject, data, tInfo, constants, expParams, input, window, stim);
    end
    
    windowCleanup(constants);
    
catch msg
    windowCleanup(constants);
    rethrow(msg)
end


end