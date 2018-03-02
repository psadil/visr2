function [ stim, window ] = setupStim( window )



%% Mondrians

% rate to cycle through mondrian images
stim.mondrian_hz = 10;
stim.mondrian_hz_refresh_cycles = 1/(window.ifi * stim.mondrian_hz);

% size of bounding square around mondrian mask
% needs to be larger than the stimulus size
stim.mondrian_size_deg = 20;

% expecting max of 450 pixels
stim.mondrian_size_pix = floor(deg2pix(window.screen_w_cm, window.winRect(3), ...
    window.view_distance_cm, stim.mondrian_size_deg));

% Maximum and minimum length of suppressor rects
stim.sqr_max_side_deg = 3; 
stim.sqr_min_side_deg = 1;

% expecting max and min of 40 and 15
stim.sqr_max_side_pix = floor(deg2pix(window.screen_w_cm, window.winRect(3), ...
    window.view_distance_cm, stim.sqr_max_side_deg));
stim.sqr_min_side_pix = floor(deg2pix(window.screen_w_cm, window.winRect(3), ...
    window.view_distance_cm, stim.sqr_min_side_deg));

% number of squares to draw
stim.n_squares = 1000; 

%% Fixations
stim.fixSize_deg = 1;
stim.fixSize_pix = deg2pix(window.screen_w_cm, window.winRect(3), ...
    window.view_distance_cm, stim.fixSize_deg);

stim.fixLineSize = 2;

% cue point coordinates
stim.fix_rect = ...
    [[[-stim.fixSize_pix/2, stim.fixSize_pix/2];[0,0]],...
    [[0,0];[-stim.fixSize_pix/2, stim.fixSize_pix/2]]];

%% Stimulus placement

stim.image_size_deg = 13;

% expecting 300 x 300
stim.image_size_pix = deg2pix(window.screen_w_cm, window.winRect(3), ...
    window.view_distance_cm, stim.image_size_deg);

stim.image_dst_rect = CenterRect([0 0 stim.image_size_pix stim.image_size_pix],...
    Screen('Rect',window.pointer));

stim.noise_size_deg = stim.mondrian_size_deg;
stim.noise_size_pix = stim.mondrian_size_pix;
stim.noise_dst_rect = CenterRect([0 0 stim.noise_size_pix stim.noise_size_pix],...
    Screen('Rect',window.pointer));

%% Text Placement

stim.text_note_placement = window.winRect(4) * .8;

end

