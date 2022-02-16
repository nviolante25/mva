function [nls, nGC, nNLA, nBars, nResidual] = GG(in_img, image_type, rho, theta, k)
%%   GG(input, image_type, rho, theta, k)
%     Gestaltic Grouping of Line Segments
%     inputs:
%     in_img: input image
%     image_type: input image format (e.g. png jpg etc)
%     rho: maximum distance between line segment tips for a good continuation (in pixels)
%     theta: maximum angle between line segments for a good continuation (in degree)
%     k: maximum number of segments in a grouping
%
%  The output is the number of initial line segments, good continuations, bars,
%   non-local alignments, residual ungrouped segments, respectively. Output is printed out
%   in n_det.txt file.
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

% path to ghostscript package for saving output images
path2gs = '/usr/bin/gs';

if isdeployed
    rho = str2double(rho);
    theta = str2double(theta);
    k = str2double(k);
end

%% Read input image
X=imread([in_img '.' image_type]);
if(size(X,3)>1)
    X = rgb2gray(X);
end
X = double(X);
[m, n] = size(X);

%% Create segment structure
Segments = struct('strtip', [], 'endtip', [], 'len', [], 'width', [], 'type', [], 'mdlpnts', [], 'par', []);
nS = 0;
%% LSD
% Computing initial line segments using LSD algorithm
% http://www.ipol.im/pub/art/2012/gjmr-lsd/
output_lsd=lsd(X);
nls = size(output_lsd,1);
for i=1:nls
    tip1 = [output_lsd(i,1) output_lsd(i,2)];
    tip2 = [output_lsd(i,3) output_lsd(i,4)];
    [Segments, nS] = fillSegmentsStruct(Segments, nS, tip1, tip2, norm(tip1-tip2), 1, [], []);
end
% Write the LSD image
write_eps(Segments, m, n, [in_img '_LSD.eps'], 1);
eps2xxx([in_img '_LSD.eps'],{'png'},path2gs,1);
delete([in_img '_LSD.eps']);

% Make Adjacency Matrix of LSD line segments
adjM = makeAdjMatrix(Segments,rho,theta);

%% Calculate non-local alignments
lstruct = findNLA(adjM,k,m,n); %find the potential NLAs
lstruct = sortChains(lstruct); %sort them according to NFA
lc = LineChain(nS, lstruct);   %match line segnemtns and NLAs
lstruct = findCurves(lstruct,lc); %Calculate final NLAs
[Segments, nS] = addSeg(Segments, nS, lstruct, 2);
% Write the NLA image
write_eps(Segments, m, n, [in_img '_NLA.eps'], 2);
eps2xxx([in_img '_NLA.eps'],{'png'},path2gs);
nNLA = sum([Segments.type]==2);
delete([in_img '_NLA.eps']);

%% Find Good continuations

chains = findChains(adjM,k,m,n); %Find potential GCs
chains = sortChains(chains);  %Sort them based on NFA
lc = LineChain(sum([Segments.type]==1), chains); %match line segnemtns and GCs
chains = findCurves(chains,lc);%Calculate final GCs
[Segments, nS] = addSeg(Segments, nS, chains, 3);
%Write outpur GC image
write_eps(Segments, m, n, [in_img '_GC.eps'], 3);
eps2xxx([in_img '_GC.eps'],{'png'},path2gs);
nGC = sum([Segments.type]==3);
delete([in_img '_GC.eps']);


%% Parallel Segments
%Re-calculate adjacency matrix to also take into account NLAs
adjM_Bar = makeAdjMatrix_Bar(Segments,rho);
BarsStruct = CalBars(adjM_Bar,m,n); %Find initial bars
Bars = findBars(BarsStruct, sum([Segments.type]<3)); %Calculate final bars based on NFA
[Segments, nS] = addSeg(Segments, nS, Bars, 4);
%Write output Bar image
write_eps(Segments, m, n, [in_img '_Bars.eps'], 4);
eps2xxx([in_img '_Bars.eps'],{'png'},path2gs);
nBars = sum([Segments.type]==4);
delete([in_img '_Bars.eps']);

%% Write output Residual image
write_residual_eps(Segments, m, n, [in_img '_Residual.eps'],[Segments.par]);
eps2xxx([in_img '_Residual.eps'],{'png'},path2gs);
delete([in_img '_Residual.eps']);
nResidual = sum([Segments.type]==1) - length(unique([Segments.par]));

%% Write web interface variables
fid = fopen('./algo_info.txt', 'w');
fwrite(fid, sprintf('nls=%d\n', nls));
fwrite(fid, sprintf('nGC=%d\n', nGC));
fwrite(fid, sprintf('nBars=%d\n', nBars));
fwrite(fid, sprintf('nNLA=%d\n', nNLA));
fwrite(fid, sprintf('nResidual=%d\n', nResidual));
fclose(fid);
