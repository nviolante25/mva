function Bars = CalBars(adj,m,n)
%% Bars = CalBars(adj,m,n)
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
nL = size(adj, 1);
cur = 1;
Bars = [];

for i=1:nL
    if(isempty(adj{i})) continue; end
    for k=1:size(adj{i}, 1)
        j = adj{i}(k, 1);
        if(j<i) continue; end
        q = 1;
        Bars(cur,q) = i; q=q+1; %node 1
        Bars(cur,q) = j; q=q+1; %node 2
        Bars(cur,q) = adj{i}(k, 2); q=q+1; %rho
        Bars(cur,q) = adj{i}(k, 3); q=q+1; %theta
        Bars(cur,q) = calNFA_Bars(nL, adj{i}(k, 2), m,n); q=q+1; %nfa

        cur = cur + 1;
    end
end
