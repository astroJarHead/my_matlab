
function vixen_130s()
%
% test planar and parabolic mirrors (Vixen 130S Newtonian)
% nominal 13 cm F/5.5 Newtonian 289.507 arcsec/mm plate scale
% 600 nm diffraction limit seeing 0.95 arcsec
%
% Collimated ryas parrallel to axis produce diffraction spot 
% centered on screen at (999,1001). Pixels are 10 microns 
% in size and diffraction spot estimated as 3.28 microns.
%
% Rays 5 arcmin in m_y direction from X axis, collimated, produce a coma 
% spot with peak birghtness 4.92 arcmin from screen center. 
% Focal point and direction cosines are in the code 
% commented out below.
%  
% Modifed by Bob Zavala based on MatLab code with 
% Copyright: Yury Petrov, 2016
%

% create a container for optical elements (Bench class)
bench = Bench;

% add optical elements in the order they are encountered by light rays
% units for diameter, w, h are cm for the Vixen example.
% The 1cm screen with 2000 x 2000 pixels has 5 micron pixels

% back surface of the circular  mirror diagonal
mirror1 = Plane( [ 16.30 0 0 ], 4.8, { 'mirror' 'air' } ); % pay attention to the glass order here!
mirror1.rotate( [ 0 0 1 ],  -pi / 4 );
bench.append( mirror1 );

% parabolic mirror
mirror2 = Lens( [ 71.247 0 0 ], 12.954, -142.494, -1, { 'air' 'mirror' } ); % pay attention to the glass order here!
bench.append( mirror2 );

% front surface of the circular mirror diagonal assuming 0.25 in thick
mirror3 = Plane( [ 16.55 0 0 ], 4.8, { 'mirror' 'air' } ); % pay attention to the glass order here!
mirror3.rotate( [ 0 0 1 ],  -pi / 4 );
bench.append( mirror3 );

% screen
screen = Screen( [ 16.549 -16.5824 0 ], 1, 1, 2000, 2000 );
screen.rotate( [ 0 0 1 ], -pi/2 );
bench.append( screen );

% create collimated rays
% second vector [ 1 0 0 ] is direction as direction cosines
% ray bundle parallel to x-axis, optical axis as l_x = 1, m_y = n_z = 0
% Ray bundle 5 arcmin x angle in y-direction, 0 deg z angle:
% yields a coma image screen at y = -16.5825
%            l_x = 0.9999989, m=y = 0.0014544, n_z = 0
%    y focus for screen to -16.5825 
% and brightest spot in coma 4.92 arcmin from center of screen
l_x = 0.9999989;
m_y = 0.0014544;
n_z = 0.0;

% sanity check on direction cosines
dir_cos_sqrs = l_x^2 + m_y^2 + n_z^2;
dir_cosine_chk = abs(dir_cos_sqrs - 1)/1.0
if dir_cosine_chk > 0.00001 
    error('Squares of Direction cosines must sum to 1.0 !!!')
end
% If error did not trip, continue

nrays = 500;
rays_in = Rays( nrays, 'collimated', [ 0 0 0 ], [ l_x m_y n_z ], 15, 'hexagonal' );

fprintf( 'Tracing rays...\n' );
rays_through = bench.trace( rays_in, 0 ); % the second parameter set to 0 enables ray tracing for rays missing some elmeents on the bench
% rays_through(5) are the rays that reach the screen as:
% rays_through(1) are the starting rays at X=0
% rays_through(2) are rays that reach the non-reflective side of the diagonal
% rays_through(3) are rays that reflect off the primary mirror
% rays_through(4) are rays that reflect off the diagonal
% rays_through(5) are rays that reach the screen
% To get the position of rows (rays) 510-512 on the screen (5) (if the code is stopped):
% rays_through(5).r(510:512,:)

% draw bench elements and draw rays as arrows
bench.draw( rays_through, 'arrows', [], [ 3 0 2 1 .1 ] );  % display everything, specify arrow length for each bench element

% get the screen image in high resolution
nrays = 10000;
rays_in = Rays( nrays, 'collimated', [ 0 0 0 ], [ l_x m_y n_z ], 58, 'hexagonal' );
bench.trace( rays_in, 0 );
figure( 'Name', 'Image on the screen', 'NumberTitle', 'Off' );
imshow( screen.image, [] );
% Use xlim and ylim if only a subsection of screen is desired. 
% xlim([400,500]);
% ylim([450,550]);
axis on;
grid on;
colorbar;
xlabel('X coordinate')
ylabel('Z coordinate')
title('Screen Image (Y coordinate is focus position)')
% screen.surf provides a three-d surface plot
% imshow ( screen.surf, []);

% test some commands
% draw a ray fan as the rays exit and proceed out from the focus
% rays_through(5).draw(0.5)

% Find the x,y,z coordiantes of the focsl point on the screen
fp_txt = 'Focal point traced to:';
disp(fp_txt);
rays_through(5).focal_point()


end
