function [adjMatrix] = makeAdjMatrix(segs,rho_max,theta_max)
%% [adjMatrix] = makeAdjMatrix(segs,rho_max,theta_max)
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
nL = length(segs);
adjMatrix = cell(nL,1);
num_neighbors = 3;

for i=1:nL  
    for j=i+1:nL
        [rho, theta, st] = isAdjacent(segs(i),segs(j),rho_max,theta_max);
        if (rho~=-1)
            ind = size(adjMatrix{i}, 1)+1;
            adjMatrix{i}(ind, 1) = j;
            adjMatrix{i}(ind, 2) = rho;
            adjMatrix{i}(ind, 3) = theta;
            adjMatrix{i}(ind, 4) = st;           
            
            ind = size(adjMatrix{j}, 1)+1;
            adjMatrix{j}(ind, 1) = i;
            adjMatrix{j}(ind, 2) = rho;
            adjMatrix{j}(ind, 3) = theta;
            adjMatrix{j}(ind, 4) = 1-st;     
        end
    end
end

for i=1:nL
    mat = adjMatrix{i};
    if(~size(mat,1))
        continue;
    end
    mat1 = mat(mat(:,4)==1,:);
    mat2 = mat(mat(:,4)==0,:);
    
    if(size(mat1,1)>num_neighbors)
        temp = mat1;
        [~, ids] = sort(temp(:,2));
        mat1 = temp(ids(1:num_neighbors),:);
        
        for j=num_neighbors+1:length(ids)
            j_ = temp(ids(j),1);
            index = find(adjMatrix{j_}(:,1)==i);
            adjMatrix{j_}(index,:) = [];
        end
    end
    
    if(size(mat2,1)>num_neighbors)
        temp = mat2;
        [~, ids] = sort(temp(:,2));
        mat2 = temp(ids(1:num_neighbors),:);
        
        for j=num_neighbors+1:length(ids)
            j_ = temp(ids(j),1);
            index = find(adjMatrix{j_}(:,1)==i);
            adjMatrix{j_}(index,:) = [];
        end
    end
    
    adjMatrix{i} = [mat1; mat2];
end
