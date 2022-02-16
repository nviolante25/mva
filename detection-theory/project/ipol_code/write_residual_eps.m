function write_residual_eps(segs, m, n, filename, grouped)
%% write_residual_eps(segs, m, n, filename, grouped)
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
%% Set color
ns = sum([segs.type]==1);
indx = find([segs.type]==1);

color = zeros(ns, 3);

%%
eps = fopen(filename,'w');

fprintf(eps,'%%!PS-Adobe-3.0 EPSF-3.0\n');
fprintf(eps,'%%%%BoundingBox: 0 0 %d %d\n',n,m);
fprintf(eps,'%%%%Creator: LSD, Line Segment Detector\n');
fprintf(eps,'%%%%Title: (%s)\n',filename);
fprintf(eps,'%%%%EndComments\n');

width = 2;

for i = 1:length(indx)
    s = indx(i);
    
    if(sum(grouped==s))
        continue;
    end
    
    strtip = segs(s).strtip;
    endtip = segs(s).endtip;
    fprintf( eps,'newpath %f %f moveto %f %f lineto %f %f %f setrgbcolor %f setlinewidth stroke\n', ...
        strtip(1), m - strtip(2), endtip(1), m - endtip(2), color(i,1), color(i,2), color(i,3), width );
end

fprintf(eps,'showpage\n');
fprintf(eps,'%%%%EOF\n');
fclose(eps);
