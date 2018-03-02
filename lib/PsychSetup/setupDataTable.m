function data = setupDataTable( input, expt, varargin )
%setupDataTable setup data table for this participant.

rng('shuffle');
scurr = rng; % set up and seed the randon number generator

%% Study part of table
switch expt
    case 'occularDominance'
        data = readtable('occularDominance_blocking.csv');
        data = data(data.participant == input.subject,:);
        n = size(data,1);
        
        data.eyes = repelem({[0,0]}, n)';
        data.eyes(strcmp(data.arrow_to,{'left'})) = {[1,0]};
        data.eyes(strcmp(data.arrow_to,{'right'})) = {[0,1]};   
        
    case {'visualRecollection', 'practice'}
        data = readtable('data_blocking.csv');
        data = data(data.participant == input.subject,:);
        n = size(data,1);
        
        domEye = varargin{1};
        
        data.eyes = repelem({[0,0]}, n)';
        if strcmp(domEye, {'right'})
            eye_fill = {[1,0]};
        else
            eye_fill = {[0,1]};
        end
        data.eyes(strcmp(data.trial_type,{'CFS'})) = eye_fill;
        data.pas = cell(n,1);
        data.name_dur_max = str2double(data.name_dur_max);
end

data.seed = repelem(scurr.Seed, n)';
data.rt_robo = ones([n,1]) * 0.2;
data.response = cell(n,1);
data.exitflag = cell(n,1);

end
