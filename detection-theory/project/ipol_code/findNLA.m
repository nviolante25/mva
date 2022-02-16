function SLines = findNLA(adj,K,m,n)
%% SLines = findNLA(adj,K,m,n)
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

SLines = cell(2,1);
SLines{1} = zeros(K,1);
SLines{2} = [];
SLines{3} = [];

thr = 3; %used as a metric to show if two segments are on straight line 
% Lines of length 2

for i=1:nL
    if(isempty(adj{i})) continue; end
    for k=1:size(adj{i}, 1)
        j = adj{i}(k, 1);
        if(j<i) continue; end
        if(adj{i}(k, 3)>thr) continue; end  % the angle is larger than acceptable as straight line
        SLines{1}(2) = SLines{1}(2)+1;
        cur = SLines{1}(2);
        SLines{2}{cur} = [i,j];q=1;
        SLines{3}(cur,q) = 2; q=q+1; %number of segments
        SLines{3}(cur,q) = adj{i}(k, 2); q=q+1; %rho
        SLines{3}(cur,q) = adj{i}(k, 3); q=q+1; %theta
        %SLines{3}(cur,q) = min(length_(ls{i}),length_(ls{j})); q=q+1; % minimum segment length in chain
        %SLines{3}(cur,q) = max(length_(ls{i}),length_(ls{j})); q=q+1; % maximum segment length in chain
        SLines{3}(cur,q) = calNFA_NLA(nL, 2, SLines{3}(cur,2), m,n); q=q+1; %nfa
        SLines{3}(cur,q) = i; q=q+1; %free node 1
        SLines{3}(cur,q) = j; q=q+1; %free node 2
        SLines{3}(cur,q) = 1-adj{i}(k, 4); q=q+1; %free tip 1
        SLines{3}(cur,q) = adj{i}(k, 4); %free tip 2
        SLines{4}{cur} = [i,j];
    end
end

% Lines of length more than 3

for len=3:K
    strt = size(SLines{3},1)+1;
    sprev = strt - SLines{1}(len-1);
    
    cur = strt;
    for i=sprev:strt-1
        fn1 = SLines{3}(i,5);
        ft1 = SLines{3}(i,7);
        %if(isempty(adj{fn1})) continue; end
        
        for k=1:size(adj{fn1}, 1)
            j = adj{fn1}(k, 1);
            if( adj{fn1}(k,4)==ft1)
                if(adj{fn1}(k, 3)>thr) continue; end  % the angle is larger than acceptable as straight line
                if(~findbetween(SLines{2}, sort([SLines{2}{i} j]), strt, cur-1) && ~sum(SLines{2}{i}==j))
                    SLines{2}{cur} = sort([SLines{2}{i} j]);q=1;
                    SLines{3}(cur,q) = len; q=q+1; %number of line segments 
                    SLines{3}(cur,q) = max(adj{fn1}(k,2), SLines{3}(i,2)); q=q+1; %rho
                    SLines{3}(cur,q) = max(adj{fn1}(k,3), SLines{3}(i,3)); q=q+1; % theta
                    %SLines{3}(cur,q) = min(length_(ls{j}),SLines{3}(i,4)); q=q+1; % minimum segment length in chain
                    %SLines{3}(cur,q) = max(length_(ls{j}),SLines{3}(i,5)); q=q+1; % maximum segment length in chain
                    SLines{3}(cur,q) = calNFA_NLA(nL, len, SLines{3}(cur,2), m,n); q=q+1; %nfa
                    SLines{3}(cur,q) = j; q=q+1; %free node 1
                    SLines{3}(cur,q) =  SLines{3}(i,6); q=q+1; %free node 2
                    SLines{3}(cur,q) = adj{fn1}(k,4); q=q+1; %free tip 1
                    SLines{3}(cur,q) =  SLines{3}(i,8); %free tip 2
                    SLines{4}{cur} = [j SLines{4}{i}];
                    cur = cur + 1;
                end
            end
        end
        
        fn2 = SLines{3}(i,6);
        ft2 = SLines{3}(i,8);
        %if(isempty(adj{fn2})) continue; end
        
        for k=1:size(adj{fn2}, 1)
            j = adj{fn2}(k, 1);
            if(adj{fn2}(k,4)==ft2)
                if(adj{fn2}(k, 3)>thr) continue; end  % the angle is larger than acceptable as straight line                
                if(~findbetween(SLines{2}, sort([SLines{2}{i} j]), strt, cur-1) && ~sum(SLines{2}{i}==j))
                    SLines{2}{cur} = sort([SLines{2}{i} j]);q=1;
                    SLines{3}(cur,q) = len; q=q+1; %number of line segments 
                    SLines{3}(cur,q) = max(adj{fn2}(k,2), SLines{3}(i,2)); q=q+1; %rho
                    SLines{3}(cur,q) = max(adj{fn2}(k,3), SLines{3}(i,3)); q=q+1; % theta
                    %SLines{3}(cur,q) = min(length_(ls{j}),SLines{3}(i,4)); q=q+1; % minimum segment length in chain
                    %SLines{3}(cur,q) = max(length_(ls{j}),SLines{3}(i,5)); q=q+1; % maximum segment length in chain
                    SLines{3}(cur,q) = calNFA_NLA(nL, len, SLines{3}(cur,2), m,n); q=q+1; %nfa
                    SLines{3}(cur,q) =  SLines{3}(i,5); q=q+1; %free node 1
                    SLines{3}(cur,q) = j; q=q+1; %free node 2
                    SLines{3}(cur,q) =  SLines{3}(i,7); q=q+1; %free tip 1
                    SLines{3}(cur,q) = adj{fn2}(k,4); %free tip 2
                    SLines{4}{cur} = [SLines{4}{i} j];
                    cur = cur + 1;
                end
            end
        end
        
    end
    SLines{1}(len) = cur - strt;    
end
