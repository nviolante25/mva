function [bars,barStruct] = findBars(barStruct, nl)
%% [bars,barStruct] = findBars(barStruct, nl)
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
bars = [];

if(isempty(barStruct))
    return;
end

%% Sort Bars according to NFA
[~, ind] = sort(barStruct(:,5));

C = barStruct;

for i=1:length(ind)
    barStruct(i,:) = C(ind(i),:);
end

%%  

nb = size(barStruct,1);
lb = cell(nl, 1);

for b=1:nb
    lb{barStruct(b,1)} = [lb{barStruct(b,1)} b]; %First line in bar
    lb{barStruct(b,2)} = [lb{barStruct(b,2)} b]; %Second line in bar
end

%%

nbar = 0;
bars = []; 
eps = 1;

valid = ones(nb,1);

for b=1:nb
    if(barStruct(b,5)<eps)
        if(valid(b))
            nbar = nbar + 1;
            bars{nbar} = [barStruct(b,1) barStruct(b,2)];
            barStruct(b,6) = nbar;
            valid(b) = 0;
            
            %remove subchains
            for l=1:length(bars{nbar})
                li = bars{nbar}(l);
                for c1=1:length(lb{li})
                    valid(lb{li}(c1)) = 0;
                end
            end
            
        end
    else
        return;
    end
end
