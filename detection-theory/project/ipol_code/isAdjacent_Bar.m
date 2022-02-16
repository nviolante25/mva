function [r, t] = isAdjacent_Bar(seg1,seg2,rho)
%% [r, t] = isAdjacent_Bar(seg1,seg2,rho)
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
line1(1,:) = seg1.strtip;
line1(2,:) = seg1.endtip;
line2(1,:) = seg2.strtip;
line2(2,:) = seg2.endtip;

angle_thr = 5;
dist_thr = 5;

r = -1;t=-1;
flag = 0;
for i=1:2 %the two tips of each line
    for j=1:2
        if(i==j) continue; end
        dist_tip1 = norm(line1(i,:)-line2(j,:));
        
        p12 = line1(i,:); p21 = line2(j,:);
        p11 = line1; p11(i,:)=[]; p22 = line2; p22(j,:)=[];
        dist_tip2 = norm(p11-p22);
        
        p1 = p12 - p11;
        p2 = p22 - p21;
        ang = radtodeg(acos(p1*p2'/(norm(p1)*norm(p2)))); %line i , j        
        
        if(dist_tip1>rho || dist_tip2>rho || ang>180+angle_thr || ang<180-angle_thr) continue; end        
        
        r = mean([dist_tip1 dist_tip2]);
        t = abs(180-ang);

        flag = 1;
        
    end
    if(flag)
        if(r<=rho/3) r = rho/3;
        elseif(r<=2*rho/3) r = 2*rho/3;
        else r = rho;
        end
        return;
    end
end
