function f = lowpassfilter(sze, cutoff, n)
% LOWPASSFILTER - Constructs a low-pass Butterworth filter.
%
% usage: f = lowpassfilter(sze, cutoff, n)
%
% where: sze    is a two element vector specifying the size of filter
%               to construct [rows cols].
%        cutoff is the cutoff frequency of the filter 0 < cutoff < 0.5
%        n      is the order of the filter, the higher n is the sharper
%               the transition is. (n must be an integer >= 1).
%
% The frequency origin of the returned filter is at the corners.
%
% See also: HIGHPASSFILTER, HIGHBOOSTFILTER, BANDPASSFILTER

% Copyright (c) 1999 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% http://www.csse.uwa.edu.au/
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.

if cutoff < 0 | cutoff > 0.5
    error('cutoff frequency must be between 0 and 0.5');
end

if rem(n,1) ~= 0 | n < 1
    error('n must be an integer >= 1');
end

rows = sze(1);
cols = sze(2);

% X and Y matrices with ranges normalised to +/- 0.5
x =  (ones(rows,1) * [1:cols]  - (fix(cols/2)+1))/cols;
y =  ([1:rows]' * ones(1,cols) - (fix(rows/2)+1))/rows;

radius = sqrt(x.^2 + y.^2);        % A matrix with every pixel = sqrt(x^2 + y^2)
f = 1 ./ (1.0 + (radius ./ cutoff).^(2*n));   % The filter
