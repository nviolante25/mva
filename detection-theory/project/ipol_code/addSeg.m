function [segs, ns] = addSeg(segs, ns, lstruct, type)
%% [segs, ns] = addSeg(segs, ns, lstruct, type)
%  For input output description follow GG.m script and comments
%
%  Written by Boshra Rajaei 3/11/16
%  b.rajaei@sadjad.ac.ir
%
%  Copyright (c) 2016-2017 boshra rajaei <b.rajaei@sadjad.ac.ir>
%
%  This program is a free software: you can redistribute it and/or modify
%  it under the terms of the GNU Affero General Public License as
%  published by the Free Software Foundation, either version 3 of the
%  License, or (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%  GNU Affero General Public License for more details.
%
%  You should have received a copy of the GNU Affero General Public License
%  along with this program. If not, see <http://www.gnu.org/licenses/>.
%
%%

if(type==4)
    nb = length(lstruct);
    for i=1:nb
        tip1 = (segs(lstruct{i}(1)).strtip + segs(lstruct{i}(2)).endtip)/2;
        tip2 = (segs(lstruct{i}(1)).endtip + segs(lstruct{i}(2)).strtip)/2;
        len = norm(tip1-tip2);
        [segs, ns] = fillSegmentsStruct(segs, ns, tip1, tip2, len, type, [], lstruct{i});        
    end
    return;
end

if(isempty(lstruct{3}))
    return;
end

nl = max(lstruct{3}(:,9));

for ls=1:nl
    [~, ind] = max(lstruct{3}(:,9)==ls);
    if(~lstruct{3}(ind,7))
        st = 0;
        tip1 = segs(lstruct{3}(ind,5)).strtip;
    else 
        st = 1;
        tip1 = segs(lstruct{3}(ind,5)).endtip;
    end
    
    if(~lstruct{3}(ind,8))
        tip2 = segs(lstruct{3}(ind,6)).strtip;
    else 
        tip2 = segs(lstruct{3}(ind,6)).endtip;
    end
    
    if(type==2)
        len = norm(tip1-tip2);
    else
        len = 0;
        for i=1:length(lstruct{4}{ind})
            len = len + segs(lstruct{4}{ind}(i)).len;
        end
    end
    
    mdlpnts = cell(length(lstruct{4}{ind})-1, 1);
    for i=1:length(lstruct{4}{ind})-1
        li1 = lstruct{4}{ind}(i);
        li2 = lstruct{4}{ind}(i+1);
        if(~st)
            mid = (segs(li1).endtip+segs(li2).strtip)/2;
        else 
            mid = (segs(li1).strtip+segs(li2).endtip)/2;
        end
        mdlpnts{i} = mid;
    end
    
    [segs, ns] = fillSegmentsStruct(segs, ns, tip1, tip2, len, type, mdlpnts, lstruct{4}{ind});
end
