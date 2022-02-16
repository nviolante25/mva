function [chains] = findCurves(chains, lc)
%% [chains] = findCurves(chains, lc)
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
nc = sum(chains{1});
ncu = 0;
eps = 1;

valid = ones(nc,1);

for c=1:nc
    if(chains{3}(c,4)<eps)
        if(valid(c))% && chains{3}(c,1)>=4 && sum(adjM{chains{3}(c,5)}(:,1)==chains{3}(c,6)))
            ncu = ncu + 1;
            chains{3}(c,9) = ncu;
            valid(c) = 0;
            
            %remove subchains
            for l=1:length(chains{2}{c})
                li = chains{2}{c}(l);
                for c1=1:length(lc{li})
                    valid(lc{li}(c1)) = 0;
                end
            end
            
        end
    else
        return;
    end
end
