function [adjMatrix] = makeAdjMatrix_Bar(segs,rho)
%% [adjMatrix] = makeAdjMatrix_Bar(segs,rho)
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
nL = sum([segs.type]<3);
adjMatrix = cell(nL,1);

for i=1:nL        
    for j=i+1:nL
        [r, t] = isAdjacent_Bar(segs(i),segs(j),rho);
        if (r~=-1)
            ind = size(adjMatrix{i}, 1)+1;
            adjMatrix{i}(ind, 1) = j;
            adjMatrix{i}(ind, 2) = r;
            adjMatrix{i}(ind, 3) = t;        
            
            ind = size(adjMatrix{j}, 1)+1;
            adjMatrix{j}(ind, 1) = i;
            adjMatrix{j}(ind, 2) = r;
            adjMatrix{j}(ind, 3) = t;   
        end
    end
end
