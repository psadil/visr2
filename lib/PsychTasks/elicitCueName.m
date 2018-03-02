function [ response, rt, trial_start, trial_end, exitflag ] =...
    elicitCueName( window, responseHandler, tex, keys, constants, answer, cue, gonogo, duration )

%collectResponses Show arrow until participant makes response, and collect
%that response
response = {''};
rt = NaN;
exitflag = {'OK'};
trial_start = GetSecs;

switch cue
    case 'present'
        
        switch gonogo
            case 'name'
                prompt1 = 'What is this a part of?';
                prompt2 = '[Press Enter to Continue]';
                responded = false;
            otherwise
                prompt1 = 'Think about what object might be hidden';
                prompt2 = [];
                responded = true;
                keys = zeros(1,256);
                keys(KbName({'ESCAPE'})) = 1;
        end
        
        slack = .5;
        KbQueueCreate(constants.device, keys);
        vbl = Screen('Flip', window.pointer);
        firstFlip = 1;
        goRobo = 1;
        KbQueueStart(constants.device);
        onset = GetSecs;
        while GetSecs < (onset + duration)
            
            drawStimulus(window, response{1}, tex, prompt1, prompt2);
            
            vbl = Screen('Flip', window.pointer, vbl + (1/(window.ifi * 10) - slack) * window.ifi);
            if firstFlip
                trial_start = vbl;
                firstFlip = 0;
            end
            if (vbl - trial_start) > 0.2
                goRobo = 1;
            end
            
            [keys_pressed, press_times] = responseHandler(constants.device, answer, goRobo);
            if ~isempty(keys_pressed)
                [keyName, rt, exitflag] = ...
                    wrapper_keyProcess(keys_pressed, press_times, trial_start, 'name');
                
                switch keyName{1}
                    case 'BackSpace'
                        if ~isempty(response{1})
                            response = {response{1}(1:end-1)};
                        end
                    case 'space'
                        response = {[response{1}, ' ']};
                    case {'Return', 'ESCAPE'}
                        responded = true;
                        break;
                    otherwise
                        response = {[response{1}, keyName{1}]};
                end
                % extra switch necessary for robot trials, where the last response
                % might not be just Return
                switch exitflag{1}
                    case {'Return', 'ESCAPE'}
                        break;
                end
                
            end
        end
        KbQueueStop(constants.device);
        KbQueueFlush(constants.device);
        KbQueueRelease(constants.device);
        
        if ~responded
            showPromptAndWaitForResp(window, 'Try to come up with the name quicker!',...
                keys, constants, responseHandler);
        end
end
trial_end = Screen('Flip', window.pointer);

if isempty(response{:})
    response = {'NO RESPONSE'};
end

end

function drawStimulus(window, response, tex, prompt1, prompt2)

for eye = 1:2
    Screen('SelectStereoDrawBuffer',window.pointer,eye-1);
    
    Screen('DrawTexture', window.pointer, tex);
    
    % prompt participant to respond (if accepting responses)
    DrawFormattedText(window.pointer, prompt1, ...
        window.xCenter-300, window.winRect(4)*.8);
    DrawFormattedText(window.pointer, response, window.xCenter+100, window.winRect(4)*.8);
    DrawFormattedText(window.pointer, prompt2, ...
        'center', window.winRect(4)*.9);
    
end
Screen('DrawingFinished',window.pointer);

end
