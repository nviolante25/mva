function [segs, ns] = fillSegmentsStruct(segs, ns, tip1, tip2, len, t, mdlpnts, par) 
%% [segs, ns] = fillSegmentsStruct(segs, ns, tip1, tip2, len, t, mdlpnts, par)
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
id = ns + 1;

width = 5;
if(t==4)
    width = 8;
end

segs(id).strtip = tip1;
segs(id).endtip = tip2;
segs(id).len = len;
segs(id).width = width;
segs(id).type = t;
segs(id).mdlpnts = mdlpnts;
segs(id).par = par;

ns = id;
