function drawMaskedStimulus(window, prompt, eyes, stim, ...
    image_tex, alpha_tex, tex_dst_rect, type)

switch type
    case 'mondrians'
        % intensities = (unidrnd(256, stim.n_squares) - 1)/255;
        % truncated normal because that's what was doen before
        intensities = repmat(truncnormrnd([1, stim.n_squares],.5, 10, 0, 1), [3, 1]);
        positions = make_mondrian_positions(stim, window);
        
    case 'white'
        noise_matrix = (50*rand(stim.noise_dst_rect(3) - stim.noise_dst_rect(1), ...
            stim.noise_dst_rect(3) - stim.noise_dst_rect(1)) + 128);
        noise_tex = Screen('MakeTexture', window.pointer, noise_matrix);
end

for eye = 1:2
    Screen('SelectStereoDrawBuffer',window.pointer,eye-1);
    
    % draw same masking image to both eyes
    switch type
        case 'mondrians'
            Screen('FillRect', window.pointer, intensities, positions);
        case 'white'
            Screen('DrawTexture', window.pointer, noise_tex, [], [], [], 0)
    end
    
    if eyes(eye)
        Screen('DrawTexture', window.pointer, image_tex,[],tex_dst_rect,[],[],alpha_tex);
    end
    
    % always draw central fixation cross
    drawFixation(window, stim.fix_rect, stim.fixLineSize, window.white);
    
    % prompt participant to respond
    DrawFormattedText(window.pointer, prompt, 'center', stim.text_note_placement);
end
Screen('DrawingFinished',window.pointer);

if strcmp(type, 'white')
    Screen('Close', noise_tex);
end


end

function positions = make_mondrian_positions(stim, window)

% positions of squares in mondrian

positions(1,:) = randi([-stim.sqr_max_side_pix, stim.mondrian_size_pix],[1, stim.n_squares]);
positions(2,:) = randi([-stim.sqr_max_side_pix, stim.mondrian_size_pix],[1, stim.n_squares]);
positions(3,:) = min(positions(1,:,:) + repmat(stim.sqr_min_side_pix,[1, stim.n_squares]) +...
    randi(stim.sqr_max_side_pix - stim.sqr_min_side_pix, [1, stim.n_squares]), stim.mondrian_size_pix);
positions(4,:) = min(positions(2,:,:) + repmat(stim.sqr_min_side_pix,[1, stim.n_squares]) +...
    randi(stim.sqr_max_side_pix - stim.sqr_min_side_pix, [1, stim.n_squares]), stim.mondrian_size_pix);

% shift mondrians to center of screen
shifts = CenterRect([0 0 stim.mondrian_size_pix - stim.sqr_max_side_pix stim.mondrian_size_pix - stim.sqr_max_side_pix], window.winRect);
shifts2 = repmat([shifts(1:2)'; shifts(1:2)'], [1, stim.n_squares]);

positions = positions + shifts2;

end
