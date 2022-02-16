function nfa = calNFA(N, k, r, t, m,n)
%% nfa = calNFA(N, k, r, t, m,n)
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
if(~t) t=0.01; end

t = degtorad(t);

c1 = 4*3;
Ntest = c1*prod(N:N-k+1);

S = t*r^2/(m*n);
A = t/pi;
PH0 = (S*A)^(k-1);

nfa = Ntest * PH0;
