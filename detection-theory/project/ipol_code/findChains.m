function Chains = findChains(adj,K,m,n)
%% Chains = findChains(adj,K,m,n)
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

Chains = cell(2,1);
Chains{1} = zeros(K,1);
Chains{2} = [];
Chains{3} = [];
Chains{4} = [];
% Chains with length 2

for i=1:nL
    if(isempty(adj{i})) continue; end
    for k=1:size(adj{i}, 1)
        j = adj{i}(k, 1);
        if(j<i) continue; end
        Chains{1}(2) = Chains{1}(2)+1;
        cur = Chains{1}(2);
        Chains{2}{cur} = [i,j];q=1;
        Chains{3}(cur,q) = 2; q=q+1; %length
        Chains{3}(cur,q) = adj{i}(k, 2); q=q+1; %rho
        Chains{3}(cur,q) = adj{i}(k, 3); q=q+1; % theta
        Chains{3}(cur,q) = calNFA(nL, 2, Chains{3}(cur,2), Chains{3}(cur,3),m,n); q=q+1; %nfa
        Chains{3}(cur,q) = i; q=q+1; %free node 1
        Chains{3}(cur,q) = j; q=q+1; %free node 2
        Chains{3}(cur,q) = 1-adj{i}(k, 4); q=q+1; %free tip 1
        Chains{3}(cur,q) = adj{i}(k, 4); %free tip 2
        Chains{4}{cur} = [i,j];
    end
end

% Chains with length more than 3
for len=3:K
    strt = size(Chains{3},1)+1;
    sprev = strt - Chains{1}(len-1);
    
    cur = strt;
    for i=sprev:strt-1
        fn1 = Chains{3}(i,5);
        ft1 = Chains{3}(i,7);
        %if(isempty(adj{fn1})) continue; end
        
        for k=1:size(adj{fn1}, 1)
            j = adj{fn1}(k, 1);
            if( adj{fn1}(k,4)==ft1)
                if(~findbetween(Chains{2}, sort([Chains{2}{i} j]), strt, cur-1) && ~sum(Chains{2}{i}==j))
                    Chains{2}{cur} = sort([Chains{2}{i} j]);q=1;
                    Chains{3}(cur,q) = len; q=q+1; %length
                    Chains{3}(cur,q) = max(adj{fn1}(k,2), Chains{3}(i,2)); q=q+1; %rho
                    Chains{3}(cur,q) = max(adj{fn1}(k,3), Chains{3}(i,3)); q=q+1; % theta
                    Chains{3}(cur,q) = calNFA(nL, len, Chains{3}(cur,2), Chains{3}(cur,3),m,n); q=q+1; %nfa
                    Chains{3}(cur,q) = j; q=q+1; %free node 1
                    Chains{3}(cur,q) =  Chains{3}(i,6); q=q+1; %free node 2
                    Chains{3}(cur,q) = adj{fn1}(k,4); q=q+1; %free tip 1
                    Chains{3}(cur,q) =  Chains{3}(i,8); %free tip 2
                    Chains{4}{cur} = [j Chains{4}{i}];
                    cur = cur + 1;
                end
            end
        end
        
        fn2 = Chains{3}(i,6);
        ft2 = Chains{3}(i,8);
        %if(isempty(adj{fn2})) continue; end
        
        for k=1:size(adj{fn2}, 1)
            j = adj{fn2}(k, 1);
            if(adj{fn2}(k,4)==ft2)
                if(~findbetween(Chains{2}, sort([Chains{2}{i} j]), strt, cur-1) && ~sum(Chains{2}{i}==j))
                    Chains{2}{cur} = sort([Chains{2}{i} j]);q=1;
                    Chains{3}(cur,q) = len; q=q+1; %length
                    Chains{3}(cur,q) = max(adj{fn2}(k,2), Chains{3}(i,2)); q=q+1; %rho
                    Chains{3}(cur,q) = max(adj{fn2}(k,3), Chains{3}(i,3)); q=q+1; % theta
                    Chains{3}(cur,q) = calNFA(nL, len, Chains{3}(cur,2), Chains{3}(cur,3),m,n); q=q+1; %nfa
                    Chains{3}(cur,q) =  Chains{3}(i,5); q=q+1; %free node 1
                    Chains{3}(cur,q) = j; q=q+1; %free node 2
                    Chains{3}(cur,q) =  Chains{3}(i,7); q=q+1; %free tip 1
                    Chains{3}(cur,q) = adj{fn2}(k,4); %free tip 2
                    Chains{4}{cur} = [Chains{4}{i} j];
                    cur = cur + 1;
                end
            end
        end
    end
    Chains{1}(len) = cur - strt;    
end
