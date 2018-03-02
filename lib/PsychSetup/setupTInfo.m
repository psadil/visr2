function tInfo = setupTInfo( constants, experiment )

switch experiment
    case 'occularDominance'
        filename = fullfile(constants.datatable_dir, 'occularDominance_tInfo_blocking.csv');
    case 'visualRecollection'
        filename = fullfile(constants.datatable_dir, 'data_tInfo_blocking.csv');        
end

tInfo = readtable(filename);

end
