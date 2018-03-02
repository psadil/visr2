function iti(window, dur, stim, varargin)

if nargin > 3
    vbl = varargin{1};
else
    vbl = Screen('Flip', window.pointer);
end

drawFixation(window, stim.fix_rect, stim.fixLineSize, 1);
vbl = Screen('Flip', window.pointer, vbl + window.ifi/2 );
WaitSecs(dur);
drawFixation(window, stim.fix_rect, stim.fixLineSize, 1);
Screen('Flip', window.pointer, vbl + window.ifi/2);

end
