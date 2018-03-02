function [ response, rt, trial_start, trial_end, vbl_realized, vbl_expected, missed, exitflag ] =...
    elicitBCFS( window, responseHandler, tex, eyes,...
    keys, stim, constants, tex_dst_rect,...
    roboRT, answer, expt, nTicks, prompt, alpha_tex, type)


%%
response = {'NO RESPONSE'};
rt = NaN;
exitflag = {'OK'};
trial_start = NaN;
vbl_realized = NaN(nTicks, 1);
missed = NaN(nTicks, 1);

slack = .5;
goRobo = 0;

KbQueueCreate(constants.device, keys);
drawFixation(window, stim.fix_rect, stim.fixLineSize, 1);

[vbl_realized(1), ~, ~, missed(1)] = Screen('Flip', window.pointer); % Display cue and prompt
vbl_expected = vbl_realized(1) + ((stim.mondrian_hz_refresh_cycles - slack) * window.ifi)*(0:nTicks-1);
            
KbQueueStart(constants.device);
for tick = 2:(nTicks-2)
    
    % for each tick, pick out one of the mondrians to draw
    drawMaskedStimulus(window, prompt, eyes, stim, tex,...
        alpha_tex(tick), tex_dst_rect, type);
    
    % flip only in sync with mondrian presentation rate
    [vbl_realized(tick), ~, ~, missed(tick)] = ...
        Screen('Flip', window.pointer, vbl_expected(tick - 1));
    
    if tick == 2
        trial_start = vbl_realized(2);
    end
    
    if (vbl_realized(tick) - trial_start) > roboRT
        goRobo = 1;
    end
    
    [keys_pressed, press_times] = responseHandler(constants.device, answer, goRobo);
    if ~isempty(keys_pressed)
        [response, rt, exitflag] = ...
            wrapper_keyProcess(keys_pressed, press_times, trial_start, expt);
        break;
    end
    
end
% note that + and minus are swapped outside of for loop
[vbl_realized(tick + 1), ~, ~, missed(tick + 1)] = ...
    Screen('Flip', window.pointer, vbl_expected(tick));

KbQueueStop(constants.device);
KbQueueFlush(constants.device);
KbQueueRelease(constants.device);

trial_end = vbl_realized(tick + 1);

if strcmpi(response,'ESCAPE')
    exitflag = {'ESCAPE'};
elseif (alpha_tex(tick) < 0.1) && (max(alpha_tex) > 0.1)
    exitflag = {'CAUGHT'};
end

end
