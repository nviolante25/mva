function write_eps(segs, m, n, filename, type)
%% write_eps(segs, m, n, filename, type)
%  m,n -> input image size;
%  type=0 -> all segments
%  type=1 -> LSD outputs
%  type=2 -> other line segments
%  type=3 -> good continuation 
%  type=4 -> bar
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

%% Set color
ns = sum([segs.type]==type);
indx = find([segs.type]==type);

if(type==1)
    color = zeros(ns, 3);
elseif(type==2 || type==3 || type==4)
    color = distinguishable_colors(ns);
end
%%
eps = fopen(filename,'w');

fprintf(eps,'%%!PS-Adobe-3.0 EPSF-3.0\n');
fprintf(eps,'%%%%BoundingBox: 0 0 %d %d\n',n,m);
fprintf(eps,'%%%%Creator: LSD, Line Segment Detector\n');
fprintf(eps,'%%%%Title: (%s)\n',filename);
fprintf(eps,'%%%%EndComments\n');

width = 2;

if(type==4)
    width = 4;
end

for i = 1:length(indx)
    s = indx(i);
    
    strtip = segs(s).strtip;
    for tip=1:length(segs(s).mdlpnts)
        endtip = segs(s).mdlpnts{tip};
        
        fprintf( eps,'newpath %f %f moveto %f %f lineto %f %f %f setrgbcolor %f setlinewidth stroke\n', ...
            strtip(1), m - strtip(2), endtip(1), m - endtip(2), color(i,1), color(i,2), color(i,3), width );
        
        strtip = endtip;
    end
    endtip = segs(s).endtip;
    fprintf( eps,'newpath %f %f moveto %f %f lineto %f %f %f setrgbcolor %f setlinewidth stroke\n', ...
            strtip(1), m - strtip(2), endtip(1), m - endtip(2), color(i,1), color(i,2), color(i,3), width );
end

fprintf(eps,'showpage\n');
fprintf(eps,'%%%%EOF\n');
fclose(eps);
