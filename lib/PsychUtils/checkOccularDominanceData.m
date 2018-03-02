function domEye = checkOccularDominanceData( data )
%checkOccularDominanceData gives analyis of data: which eye saw the arrow
%more quickly on average

data = data(~strcmpi(data.exitflag, 'CAUGHT'),:);

grpmeans = grpstats(data, 'arrow_to','nanmean', 'DataVars','rt');
[~, I] = max(grpmeans.nanmean_rt);
domEye = grpmeans.arrow_to(I);

end

