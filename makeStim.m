function [gratings annulus fixation]=makeStim(params)
    %function makeStim(params,isTarget)
    %
    % This function makes the stimulus for the detection experiment. 
    % <params> is the data struct with the params.
    % 
    % <gratings> is the sum of two perpendicular sinusoidal grating
    % <annulus> is a ring that is used to mask the square grating matrix
    %
    
    %% Create Grating
    
    % Two different gratings will be creating that are seperated by 90 degrees
    gratingOneTilt = 0;
    gratingTwoTilt = 90 * pi / 180; % convert 90 deg into radians
    
    % *** To lengthen the period of the grating, increase pixelsPerPeriod.
    spatialFrequency = 1 / params.pixelsPerPeriod; % How many periods/cycles are there in a pixel?
    radiansPerPixel = spatialFrequency * (2 * pi); % = (periods per pixel) * (2 pi radians per period)
    
    % *** If the grating is clipped on the sides, increase stimulusRadius
    halfWidthOfGrid = params.stimulusRadius;
    widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.
    
    % Creates a two-dimensional square grid.  For each element i = i(x0, y0) of
	% the grid, x = x(x0, y0) corresponds to the x-coordinate of element "i"
	% and y = y(x0, y0) corresponds to the y-coordinate of element "i"
	[x y] = meshgrid(widthArray, widthArray);
     
    % Converts meshgrid into a sinusoidal grating, where elements
	% along a line with angle theta have the same value and where the
	% period of the sinusoid is equal to "pixelsPerPeriod" pixels.
	% Note that each entry of gratingMatrix varies between minus one and
	% one; -1 <= gratingMatrix(x0, y0)  <= 1
    a = cos(gratingOneTilt)*radiansPerPixel;
	b = sin(gratingOneTilt)*radiansPerPixel;
	gratingOneMatrix = sin(a*x + b*y);
	
	% Create second grating matrix in the same way but tilted 90 degrees
	a = cos(gratingTwoTilt)*radiansPerPixel;
	b = sin(gratingTwoTilt)*radiansPerPixel;
	gratingTwoMatrix = sin(a*x + b*y);
    
    % Add the two perpendicular gratings together
    gratingMatrix = gratingOneMatrix + gratingTwoMatrix; 
    
    % Scale the grating matrix to be from 0-1
    % where 0=black and 1=white
    gratings = Scale(gratingMatrix);
    
    % Create annulus mask for stimulus
    oc_radius = size(gratings,1) / 2;    % radius of whole circle
    ic_radius = oc_radius - params.stimulusOuterRadius; % radius of inner circle
    outercircle = Circle(oc_radius);
    innercircle = Circle(ic_radius);
    annulus = outercircle;
    c_center = size(outercircle,1)/2;
    target_cells = floor(c_center-ic_radius):(floor(c_center+ic_radius)-1);
    annulus(target_cells,target_cells) = outercircle(target_cells,target_cells) - innercircle;
    
    
    %% Create fixation
    
    % outer and inner parts
    outerFixation = ones(params.outerFixationSize, params.outerFixationSize);
    innerFixation = zeros(params.innerFixationSize, params.innerFixationSize);
    diffFixation = params.outerFixationSize - params.innerFixationSize;
    if mod(diffFixation, 2) ~= 0
       error('Difference between outer and inner fixations is not divisible by 2')
    end
    
    % put it together
    target_cells = (diffFixation/2 + 1):(params.outerFixationSize - diffFixation/2);
    fixation = outerFixation;
    fixation(target_cells,target_cells) = outerFixation(target_cells,target_cells) .* innerFixation;
    
    