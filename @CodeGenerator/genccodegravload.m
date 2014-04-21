%CODEGENERATOR.GENCCODEGRAVLOAD Generate C-code for the vector of
%gravitational load torques/forces
%
% cGen.genccodegravload() generates a robot-specific C-function to compute
% vector of gravitational load torques/forces.
%
% Notes::
% - Is called by CodeGenerator.gengravload if cGen has active flag genccode or
%   genmex
% - The generated .c and .h files are wirtten to the directory specified in
%   the ccodepath property of the CodeGenerator object.
%
% Author::
%  Joern Malzahn, (joern.malzahn@tu-dortmund.de)
%
% See also CodeGenerator.CodeGenerator, CodeGenerator.gengravload, CodeGenerator.genmexgravload.

% Copyright (C) 2012-2014, by Joern Malzahn
%
% This file is part of The Robotics Toolbox for Matlab (RTB).
%
% RTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% RTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
%
% You should have received a copy of the GNU Leser General Public License
% along with RTB. If not, see <http://www.gnu.org/licenses/>.
%
% http://www.petercorke.com

function [] = genccodegravload(CGen)

%% Check for existance symbolic expressions
% Load symbolics
symname = 'gravload';
fname = fullfile(CGen.sympath,[symname,'.mat']);

if exist(fname,'file')
    tmpStruct = load(fname);
else
    error ('genmfungravload:SymbolicsNotFound','Save symbolic expressions to disk first!')
end

%% Prerequesites
CGen.logmsg([datestr(now),'\tGenerating C-code for the vector of gravitational load torques/forces' ]);

% check for existance of C-code directories
srcDir = fullfile(CGen.ccodepath,'src');
hdrDir = fullfile(CGen.ccodepath,'include');
if ~exist(srcDir,'dir')
    mkdir(srcDir);
end
if ~exist(hdrDir,'dir')
    mkdir(hdrDir);
end

funname = [CGen.rob.name,'_',symname];
funfilename = [funname,'.c'];
hfilename = [funname,'.h'];

Q = CGen.rob.gencoords;

% Convert symbolic expression into C-code
[funstr hstring] = ccodefunctionstring(tmpStruct.(symname),...
    'funname',funname,...
    'vars',{Q},'output','G');

% Create the function description header
hStruct = createHeaderStructGravity(CGen.rob,funname); % create header
hStruct.calls = hstring;
hFString = CGen.constructheaderstringc(hStruct);

%% Generate C implementation file
fid = fopen(fullfile(srcDir,funfilename),'w+');

% Includes
fprintf(fid,'%s\n\n',...
    ['#include "', hfilename,'"']);

% Function
fprintf(fid,'%s\n\n',funstr);
fclose(fid);

%% Generate C header file
fid = fopen(fullfile(hdrDir,hfilename),'w+');

% Header
fprintf(fid,'%s\n\n',hFString);

% Include guard
fprintf(fid,'%s\n%s\n\n',...
    ['#ifndef ', upper([funname,'_h'])],...
    ['#define ', upper([funname,'_h'])]);

% Includes
fprintf(fid,'%s\n\n',...
    '#include "math.h"');

% Function prototype
fprintf(fid,'%s\n\n',hstring);

% Include guard
fprintf(fid,'%s\n',...
    ['#endif /*', upper([funname,'_h */'])]);

fclose(fid);

CGen.logmsg('\t%s\n',' done!');

end

%% Definition of the function description header contents
function hStruct = createHeaderStructGravity(rob,fname)
[~,hStruct.funName] = fileparts(fname);
hStruct.shortDescription = ['Computation of the configuration dependent vector of gravitational load forces/torques for ',rob.name];
hStruct.detailedDescription = {'Given a full set of joint variables this function computes the',...
                               'configuration dependent vector of gravitational load forces/torques. Angles have to be given in radians!'};
hStruct.inputs = { ['input1: ',int2str(rob.n),'-element vector of generalized coordinates.']};
hStruct.outputs = {['G: [',int2str(rob.n),'x1] output vector of gravitational load forces/torques.']};
hStruct.references = {'Robot Modeling and Control - Spong, Hutchinson, Vidyasagar',...
    'Modelling and Control of Robot Manipulators - Sciavicco, Siciliano',...
    'Introduction to Robotics, Mechanics and Control - Craig',...
    'Modeling, Identification & Control of Robots - Khalil & Dombre'};
hStruct.authors = {'This is an autogenerated function!',...
    'Code generator written by:',...
    'Joern Malzahn (joern.malzahn@tu-dortmund.de)'};
hStruct.seeAlso = {'inertia'};
end
