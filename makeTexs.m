function stims = makeTexs(item, window, stim, type, varargin)


switch type
    case 'ARROW'
        offset_tip = deg2pix(window.screen_w_cm, window.winRect(3), ...
            window.view_distance_cm, 0.4);
        offset_inner = deg2pix(window.screen_w_cm, window.winRect(3), ...
            window.view_distance_cm, 4);
        stim.noise_dst_rect([1,3]) = stim.noise_dst_rect([1,3]) + [offset_inner, - offset_inner];
        
        fromY = window.yCenter;
        toY = window.yCenter;
        penWidth = 10;
        
        stims(1:2) = struct('tex',NaN([window.winRect(3), window.winRect(4)]));
        for tex = 1:2
            
            if tex == 1 % right-facing
                fromX = stim.noise_dst_rect(1);
                toX = stim.noise_dst_rect(3);
                tipTopX = toX - offset_tip;
            else % left-facing
                fromX = stim.noise_dst_rect(3);
                toX = stim.noise_dst_rect(1);
                tipTopX = toX + offset_tip;
            end
            
            stims(tex).tex = Screen('MakeTexture', window.pointer, ...
                ones(window.winRect(4), window.winRect(3)) .* window.gray);
            
            % horizontal part
            Screen('DrawLine', stims(tex).tex, BlackIndex(window.screenNumber),...
                fromX, fromY, ...
                toX, toY, penWidth);
            
            % upper head
            Screen('DrawLine', stims(tex).tex, BlackIndex(window.screenNumber), ...
                tipTopX, toY - offset_tip, ...
                toX, toY, penWidth);
            
            % lower head
            Screen('DrawLine', stims(tex).tex, BlackIndex(window.screenNumber), ...
                tipTopX, toY + offset_tip, ...
                toX, toY, penWidth);
        end
    case 'STUDY'
        stims = struct('id', item);
        % grab all images
        [im, ~, alpha] = arrayfun(@(x) imread(fullfile(pwd,...
            'stims', 'expt', 'whole', ['object', num2str(x.id), '_noBkgrd']), 'png'), ...
            stims, 'UniformOutput', 0);
        stims.image = cellfun(@(x, y) cat(3,x,y), im, alpha, 'UniformOutput', false);
        
        % make textures of images
        stims.tex = arrayfun(@(x) Screen('MakeTexture',window.pointer,x.image{:}), stims);
    case 'NAME'
        stims = struct('id', item);
        stims.pair = varargin{1};
        
        % grab all images
        [im1, ~, alpha1] = arrayfun(@(x) imread(fullfile(pwd,...
            'stims', 'expt', 'apertures_double', ['object', num2str(x.id), '_paired', num2str(x.pair),'_ap1']), 'png'), ...
            stims, 'UniformOutput', 0);
        stims.image = cellfun(@(x, y) cat(3,x,y), im1, alpha1, 'UniformOutput', false);
        
        for tex = 1:length(stims)
            
            % offscreen window to be used as texture
            stims(tex).tex = Screen('MakeTexture', window.pointer, ...
                ones(window.winRect(4), window.winRect(3)) .* window.gray);
            
            %             % allow alpha blending (transparency) for this window
            %             Screen('BlendFunction', stims(tex).tex, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
            
            % draw 'paper' which will appear to occlude whole object
            Screen('FillRect', stims(tex).tex,  window.gray*.5, stim.noise_dst_rect);
            
            % make a texture out of the image to draw to this window
            texture = Screen('MakeTexture', window.pointer, stims.image{tex});
            
            % draw actual aperture, which appears appears mostly occluded
            % by paper
            Screen('DrawTexture', stims(tex).tex, texture, [], stim.image_dst_rect);
            
            % close image tex (which has been drawn)
            Screen('Close', texture);
        end
        
    case 'NOISE'
        stims = struct('id', item);
        stims.pair = varargin{1};
        
        % grab all images
        [im, ~, alpha] = arrayfun(@(x) imread(fullfile(pwd,...
            'stims', 'expt', 'bullets', ['object', num2str(x.id), '_paired', num2str(x.pair),'_ap1']), 'png'), ...
            stims, 'UniformOutput', 0);
        stims.image = cellfun(@(x, y) cat(3,x,y), im, alpha, 'UniformOutput', false);
        
        % make textures of images
        stims.tex = arrayfun(@(x) Screen('MakeTexture',window.pointer, x.image{:}), stims);
        
end


end