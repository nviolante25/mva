function chains = sortChains(chains)
%% chains = sortChains(chains)
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
if(isempty(chains{3}))
    return;
end

[~, ind] = sort(chains{3}(:,4));

C = chains;

for i=1:length(ind)
    chains{2}{i} = C{2}{ind(i)};
    chains{3}(i,:) = C{3}(ind(i),:);
    chains{4}{i} = C{4}{ind(i)};
end
