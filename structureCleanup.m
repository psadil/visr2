function structureCleanup(expt, subject, data, tInfo, constants, varargin)
% receives structures of values relating to experiment and saves them all.
% constants must be defined so that it is known where to save the variables

constants.exp_end = GetSecs;

saveDir = fullfile(constants.subDir, expt);
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

% save every list that has been given to windowCleanup
fNamePrefix = fullfile(saveDir, ['sub-', num2str(subject, '%03d'), expt]);
writetable(data, [fNamePrefix,'.csv']);
writetable(tInfo, [fNamePrefix,'tInfo.csv']);
for nin = 5:nargin
    if nin == 5
        save([fNamePrefix,'_',inputname(nin),'.mat'],'constants');
    elseif nin == 6
        expParams = varargin{nin - 5}; %#ok<NASGU>
        save([fNamePrefix,'_','expParams','.mat'],'expParams');
    elseif nin == 7
        input = varargin{nin - 5}; %#ok<NASGU>
        save([fNamePrefix,'_','input','.mat'],'input');
    elseif nin == 8
        window = varargin{nin - 5}; %#ok<NASGU>
        save([fNamePrefix,'_','window','.mat'],'window');
    elseif nin == 9
        stim = varargin{nin - 5}; %#ok<NASGU>
        save([fNamePrefix,'_','stim','.mat'],'stim');
    end
end

end
