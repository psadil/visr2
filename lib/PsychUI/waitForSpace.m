function [] = waitForSpace(keys,constants,responseHandler)

codes = zeros(1,256);
codes(KbName({'space'})) = 1;

KbQueueCreate(constants.device, codes);
KbQueueStart(constants.device);

while 1
    
    [keys_pressed, ~] = responseHandler(constants.device, '\SPACE');
    
    if ~isempty(keys_pressed)
        break;
    end
end

KbQueueStop(constants.device);
KbQueueFlush(constants.device);
KbQueueRelease(constants.device);
end
