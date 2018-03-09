function [data, tInfo, expParams, input] =...
    runCFSgonogo( input, constants, window, responseHandler, stims, domEye, expt )

data = setupDataTable(input, expt, domEye);

expParams = setupExpParams(input.refreshRate, input.debugLevel, expt, stims, data);

tInfo = setupTInfo(constants, expt);
keys = setupKeys(expt);

%% main experimental loop
for list = 1:expParams.n_list
    
    if input.study
        if list == 1
            giveInstruction(window, keys, responseHandler, constants, expt, expParams, stims);
        else
            showPromptAndWaitForResp(window, ['You are beginning list ', ...
                num2str(list-1), ' out of ', num2str(expParams.n_list-1), ' lists in the main experiment'],...
                keys, constants, responseHandler);
            showPromptAndWaitForResp(window, 'Remember to keep your eyes focused on the cross in the center',...
                keys, constants, responseHandler);
        end
        
        %% go through study phase of this list
        for rep = 1:expParams.n_study_rep
            for trial = 1:expParams.n_trial
                
                index_data = find((data.rep == rep) & (data.trial == trial) & ...
                    (data.list == list) & (strcmp(data.phase,'study')));
                index_tInfo = find((tInfo.rep == rep) & (tInfo.trial == trial) & ...
                    (tInfo.list == list) & (strcmp(tInfo.phase, 'study')));
                
                % make texture for this trial (function is setup to hopefully handle
                % creation of many textures if graphics card could handle that
                textures = makeTexs(data.object(index_data), window, stims, 'STUDY');
                
                showPromptAndWaitForResp(window, ['Press ''j'' if you see an object.\n',...
                    'If you haven''t seen an objet and think that one won''t appear, press ''f'''],...
                    keys, constants, responseHandler);
                keys_response = keys.bCFS + keys.escape;
                
                % function that presents stim and collects response
                [data.response(index_data), data.rt(index_data),...
                    data.trial_start(index_data), data.trial_end(index_data),...
                    tInfo.vbl_realized(index_tInfo), tInfo.vbl_expected(index_tInfo),...
                    tInfo.missed(index_tInfo),...
                    data.exitflag(index_data)] = ...
                    elicitBCFS(window, responseHandler, ...
                    textures.tex, data.eyes{index_data},...
                    keys_response, stims, ...
                    constants, stims.image_dst_rect, data.rt_robo(index_data),...
                    data.answer{index_data}, ...
                    expt, max(tInfo.flip(index_tInfo)), [], tInfo.alpha(index_tInfo), 'mondrians');
                Screen('Close', textures.tex);
                
                % handle exitFlag, based on responses given
                [data.pas(index_data), esc] = wrapper_bCFS_exitFlag(data.exitflag{index_data}, data.condition{index_data},...
                    data.response{index_data}, window, keys, constants, responseHandler);
                if esc
                    return;
                end
                
                % inter-trial-interval
                iti(window, expParams.iti, stims);
            end
        end
    end
    
    %% Instruction for test
    if list == 1
        giveInstruction(window, keys, responseHandler, constants, 'NAME', expParams, stims);
    else
        showPromptAndWaitForResp(window, ['This is the first test phase for list ', num2str(list), ' out of ', num2str(expParams.n_list), ' lists\n',...
            'Please try to name the following objects.'],...
            keys, constants, responseHandler);
    end
    
    %% go through first naming phase of list
    for trial = 1:expParams.n_trial
        
        index_data = find((data.rep == 1) & (data.trial == trial) & ...
            (data.list == list) & (strcmp(data.phase, 'name')));
        
        textures = makeTexs(data.object(index_data), window, stims, 'NAME', data.pair(index_data));
        keys_response = keys.enter+keys.escape+keys.name+keys.bkspace+keys.space;
        
        [data.response(index_data), data.rt(index_data),...
            data.trial_start(index_data), data.trial_end(index_data),...
            data.exitflag(index_data)] = elicitCueName(window, ...
            responseHandler, textures.tex,...
            keys_response, constants, '\ENTER',...
            data.cue{index_data}, 'name', 30);
        
        Screen('Close', textures.tex);
        switch data.exitflag{index_data}
            case 'ESCAPE'
                return;
        end
    end
    
    
    %% Instruction for (cue + go/nogo)
    if list == 1
        giveInstruction(window, keys, responseHandler, constants, 'NOISE', expParams, stims);
    else
        showPromptAndWaitForResp(window, ['This is the second test phase for list ', num2str(list), ' out of ', num2str(expParams.n_list), ' lists'],...
            keys, constants, responseHandler);
        showPromptAndWaitForResp(window, 'Remember to keep your eyes focused on the center cross',...
            keys, constants, responseHandler);
    end
    
    
    %% full test (cue + go/nogo)
    for trial = 1:expParams.n_trial
        
        index_data = find((data.rep == 1) & (data.trial == trial) & ...
            (data.list == list) & (strcmp(data.phase, 'noise')));
        
        textures = makeTexs(data.object(index_data), window, stims, 'NAME',data.pair(index_data));
        keys_response = keys.enter+keys.escape+keys.name+keys.bkspace+keys.space;
        
        % the final two arguments enable the cue to be skipped, or enforce
        % that a name is asked for
        [data.response(index_data), data.rt(index_data),...
            data.trial_start(index_data), data.trial_end(index_data),...
            data.exitflag(index_data)] = elicitCueName(window, ...
            responseHandler, textures.tex,...
            keys_response, constants, '\ENTER', ...
            data.cue{index_data}, 'EMPTY', 4);
        Screen('Close', textures.tex);
        
        switch data.exitflag{index_data}
            case 'ESCAPE'
                return;
        end
        iti(window, expParams.iti, stims);
        
        % only one should be produced by this call
        index_data = find((data.rep == 2) & (data.trial == trial) & (data.list == list) &...
            ( strcmp(data.phase, 'noise') | strcmp(data.phase, 'name')));
                
        switch data.gonogo{index_data}
            case 'name'
                
                textures = makeTexs(data.object(index_data), window, stims, 'NAME',data.pair(index_data));
                keys_response = keys.enter+keys.escape+keys.name+keys.bkspace+keys.space;
                
                [data.response(index_data), data.rt(index_data),...
                    data.trial_start(index_data), data.trial_end(index_data),...
                    data.exitflag(index_data)] = elicitCueName(window, ...
                    responseHandler, textures.tex,...
                    keys_response, constants, '\ENTER', ...
                    data.cue{index_data}, 'name', 30);
                Screen('Close', textures.tex);
                
                switch data.exitflag{index_data}
                    case 'ESCAPE'
                        return;
                end
            otherwise
                
                showPromptAndWaitForResp(window, 'Press Enter only if you see an object',...
                    keys, constants, responseHandler);
                
                index_tInfo = find((tInfo.rep == 2) & (tInfo.trial == trial) & ...
                    (tInfo.list == list) & (strcmp(tInfo.phase, 'noise')));
                
                textures = makeTexs(data.object(index_data), window, stims, 'NOISE', data.pair(index_data));
                keys_response = keys.enter + keys.escape;
                
                [data.response(index_data), data.rt(index_data),...
                    data.trial_start(index_data), data.trial_end(index_data),...
                    tInfo.vbl_realized(index_tInfo), tInfo.vbl_expected(index_tInfo),...
                    tInfo.missed(index_tInfo),...
                    data.exitflag(index_data)] = ...
                    elicitBCFS(window, responseHandler, ...
                    textures.tex, [1, 1], ...
                    keys_response, stims, ...
                    constants, stims.image_dst_rect, data.rt_robo(index_data), ...
                    data.answer{index_data}, ...
                    'noise', max(tInfo.flip(index_tInfo)), ...
                    'Press Enter only if you see an object', tInfo.alpha(index_tInfo), 'white');
                Screen('Close', textures.tex);
                
                % handle exitflag, based on responses given
                switch data.exitflag{index_data}
                    case 'ESCAPE'
                        return;
                    case 'CAUGHT'
                        showPromptAndWaitForResp(window, 'Please only respond when an image is present!',...
                            keys, constants, responseHandler);
                    otherwise
                        switch data.response{index_data}
                            case 'Return'
                                switch data.gonogo{index_data}
                                    case 'go'
                                        prompt = 'Correct! There was an object';
                                    otherwise
                                        prompt = 'Incorrect! The was no object';
                                end
                            case 'NO RESPONSE'
                                switch data.gonogo{index_data}
                                    case 'nogo'
                                        prompt = 'Correct! There was no object';
                                    otherwise
                                        prompt = 'Incorrect! There was an object';
                                end
                            otherwise
                                prompt = '';
                        end
                        showPromptAndWaitForResp(window, prompt,...
                            keys, constants, responseHandler);
                end
        end
        
        % inter-trial-interval
        iti(window, expParams.iti, stims);
    end
end


%% close up
for eye = 0:1
    Screen('SelectStereoDrawBuffer',window.pointer, eye);
    % send participant away
    DrawFormattedText(window.pointer, ['That is the end of the experiment.\n',...
        'Thanks for participating! Please find the experimenter.'], 'center', 'center');
end
Screen('Flip', window.pointer);
WaitSecs(10);

end