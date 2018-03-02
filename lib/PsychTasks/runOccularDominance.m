function [data, tInfo, expParams, input] = runOccularDominance( input, constants, window, responseHandler, stims, expt )

data = setupDataTable(input, expt);

expParams = setupExpParams(input.refreshRate, input.debugLevel, expt, stims, data);

tInfo = setupTInfo(constants, expt);

keys = setupKeys(expt);
textures = makeTexs([], window, stims, 'ARROW');

%% main experimental loop

giveInstruction(window, keys, responseHandler, constants, expt, expParams, stims);
for trial = 1:expParams.n_trial
    
    index_tInfo = find(tInfo.trial==trial);
    index_data = trial;
    
    arrowTex = selectArrowTex(textures, data.answer{trial});
    
    % function that presents arrow stim and collects response    
    [data.response(index_data), data.rt(index_data),...
        data.trial_start(index_data), data.trial_end(index_data),...
        tInfo.vbl_realized(index_tInfo), tInfo.vbl_expected(index_tInfo),...
        tInfo.missed(index_tInfo),...
        data.exitflag(index_data)] = ...
        elicitBCFS(window, responseHandler, arrowTex, data.eyes{index_data},...
        (keys.escape+keys.arrows), stims,...
        constants, [], data.rt_robo(index_data),...
        data.answer{index_data},...
        expt, max(tInfo.flip), [], tInfo.alpha(index_tInfo), 'mondrians');
    
    switch data.exitflag{index_data}
        case 'ESCAPE'
            return;
        case 'CAUGHT'
            showPromptAndWaitForResp(window, 'INCORRECT! Please wait until you are certain!',...
                keys, constants, responseHandler);
        otherwise
            switch data.response{trial}
                case 'RightArrow'
                    if strcmp('\RIGHT',data.answer{trial})
                        showPromptAndWaitForResp(window, 'Correct!',...
                            keys, constants, responseHandler);
                    else
                        showPromptAndWaitForResp(window, 'INCORRECT! Please wait until you are certain.',...
                            keys, constants, responseHandler);
                    end
                case 'LeftArrow'
                    if strcmp('\LEFT',data.answer{trial})
                        showPromptAndWaitForResp(window, 'Correct!',...
                            keys, constants, responseHandler);
                    else
                        showPromptAndWaitForResp(window, 'INCORRECT! Please wait until you are certain.',...
                            keys, constants, responseHandler);
                    end
            end
    end
    
    if mod(trial,10)==0 && trial ~= expParams.n_trial
        showPromptAndWaitForResp(window, ['You have completed ', num2str(trial), ' out of ', num2str(expParams.n_trial), ' trials'],...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, 'Remember to keep your eyes focusd on the center white cross',...
            keys,constants,responseHandler);
    end
    
    % inter-trial-interval
    iti(window, expParams.iti, stims);
    
end
Screen('Close', textures(1).tex);
Screen('Close', textures(2).tex);

end

function arrowTex = selectArrowTex(stims, correct_direction)

switch correct_direction
    case '\RIGHT'
        arrowTex = stims(1).tex;
    case '\LEFT'
        arrowTex = stims(2).tex;
end

end