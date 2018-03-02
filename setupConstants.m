function [constants, input, exit_stat] = setupConstants(input, ip)
exit_stat = 0;
% defaults = ip.UsingDefaults;

constants.exp_start = GetSecs; % record the time the experiment began
constants.device = [];

% Get full path to the directory the function lives in, and add it to the path
constants.root_dir = fileparts(mfilename('fullpath'));
constants.lib_dir = fullfile(constants.root_dir, 'lib');

% add libraries to path
path(path,constants.root_dir);
path(path, genpath(constants.lib_dir));

% Define the location of some directories we might want to use
switch input.responder
    case 'user'
        constants.savePath=fullfile(constants.root_dir,'analyses','data');
    otherwise
        constants.savePath=fullfile(constants.root_dir,'analyses','robo');
end

% instantiate the subject number validator function
subjectValidator = makeSubjectDataChecker(constants.savePath);

%% -------- GUI input option ----------------------------------------------------
% call gui for input
guiInput = getSubjectInfo('subject', struct('title', 'Participant Number', 'type', 'textinput',...
    'validationFcn', subjectValidator));
if isempty(guiInput)
    exit_stat = 1;
    return
else
    input = filterStructs(guiInput, input);
end
input.subject = str2double(input.subject);

constants.subDir = fullfile(constants.savePath, ['sub-', num2str(input.subject, '%03d')], 'beh');
if ~exist(constants.subDir, 'dir')
    mkdir(constants.subDir);
end

constants.datatable_dir = fullfile(constants.root_dir, 'lib', 'datatables', ...
    ['sub-', num2str(input.subject, '%03d')]);

end


function overwriteCheck = makeSubjectDataChecker(directory)
% makeSubjectDataChecker function closer factory, used for the purpose
% of enclosing the directory where data will be stored. This way, the
% function handle it returns can be used as a validation function with getSubjectInfo to
% prevent accidentally overwritting any data.
    function [valid, msg] = subjectDataChecker(subnum, ~)
        % the actual validation logic
        valid = false;
        
        % directories often reused, so search for run folder
        dirPathGlob = fullfile(directory, ['sub-', num2str(str2double(subnum), '%03d')]);
        if exist(dirPathGlob,'dir')
            
            msg = strjoin({'Data file for Subject', subnum, 'already exists!'}, ' ');
            return
        else
            valid = true;
            msg = 'ok';
        end
    end

overwriteCheck = @subjectDataChecker;
end

