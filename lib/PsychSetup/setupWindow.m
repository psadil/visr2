function window = setupWindow(constants,input)

window.screen_w_cm = convlength(21,'in','m')*100;
window.screen_h_cm = convlength(11.75,'in','m')*100;
window.view_distance_cm = convlength(24,'in','m')*100;

window.screenNumber = 0; % Choose a monitor to display on

% get screen resolution, set refresh rate
window.oldRes = Screen('Resolution',window.screenNumber,[],[],input.refreshRate);

window.black = BlackIndex(window.screenNumber);
window.white = WhiteIndex(window.screenNumber);
window.gray = GrayIndex(window.screenNumber);

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange', 1);

% need 32Bit for proper alpha blending, which only barely happens here (and
% maybe not at all). Though, this asks for the higher precision nicely, and
% defaults to 16 if not possible
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');

% Mondrians are drawn to offscreenwindow canvas
% PsychImaging('AddTask','General','UseFastOffScreenWindows');

Screen('Preference', 'SkipSyncTests', input.SkipSyncTests);
[window.pointer, window.winRect] = ...
    PsychImaging('OpenWindow', window.screenNumber, window.gray, input.window_rect, [], [], input.stereomode);
% Make sure the GLSL shading language is supported:
AssertGLSL;

Screen('BlendFunction', window.pointer, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

topPriorityLevel = MaxPriority(window.pointer);
Priority(topPriorityLevel);

% define some landmark locations to be used throughout
[window.xCenter, window.yCenter] = RectCenter(window.winRect);

% Get some the inter-frame interval, refresh rate, and the size of our window
window.ifi = Screen('GetFlipInterval', window.pointer);
window.hertz = FrameRate(window.pointer); % hertz = 1 / ifi
window.width = RectWidth(window.winRect);
window.height = RectHeight(window.winRect);

checkRefreshRate(window.hertz, input.refreshRate, constants);

% Font Configuration
window.fontSize = 24;

% Screen('TextFont',window.pointer, 'Arial');
Screen('TextSize',window.pointer, window.fontSize);
Screen('TextStyle', window.pointer, 1); % 0=normal,1=bold,2=italic,4=underline,8=outline,32=condense,64=extend.
Screen('TextColor', window.pointer, window.white);

end

function checkRefreshRate(trueHertz, requestedHertz, constants)

if abs(trueHertz - requestedHertz) > 2
    windowCleanup(constants);
    disp('Set the refresh rate to the requested rate')
end

end
