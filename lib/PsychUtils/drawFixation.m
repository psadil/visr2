function drawFixation(window, fix_xy, fix_width, color)

for eye = 0:1
    Screen('SelectStereoDrawBuffer',window.pointer,eye);
    Screen('DrawLines', window.pointer, fix_xy, fix_width, color, [window.xCenter, window.yCenter]);
end

end


