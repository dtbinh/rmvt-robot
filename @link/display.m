%DISPLAY	display the value of a LINK object

%	Copright (C) Peter Corke 1999
function display(l, full)

	disp(' ');
	disp([inputname(1), ' = '])
	disp(' ');
	disp(['  ' char(l)])
	disp(' ');

	if nargin > 1,
		if ~isempty(l.m)
			fprintf('  m    = %f\n', l.m)
		end
		if ~isempty(l.r)
			fprintf('  r    = %f %f %f\n', l.r);
		end
		if ~isempty(l.I)
			fprintf('  I    = | %f %f %f |\n', l.I(1,:));
			fprintf('         | %f %f %f |\n', l.I(2,:));
			fprintf('         | %f %f %f |\n', l.I(3,:));
		end
		if ~isempty(l.Jm)
			fprintf('  Jm   = %f\n', l.Jm);
		end
		if ~isempty(l.B)
			fprintf('  B    = %f\n', l.B);
		end
		if ~isempty(l.Tc)
			fprintf('  Tc   = %f(+) %f(-)\n', l.Tc(1), l.Tc(2));
		end
		if ~isempty(l.G)
			fprintf('  G    = %f\n', l.G);
		end
		if ~isempty(l.qlim)
			fprintf('  qlim = %f to %f\n', l.qlim(1), l.qlim(2));
		end
	end
