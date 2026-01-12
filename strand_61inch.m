
function strand_61inch()
%
% Model for the 61-inch Strand astrometric reflector
% 
% Modifed by Bob Zavala based on MatLab code with 
% Copyright: Yury Petrov, 2016
%

% create a container for optical elements (Bench class)
bench = Bench;

% add optical elements in the order they are encountered 
% by light rays
% units for diameter, w, h are mm 
% 

% set distance of secondary from ray source
dist_sec = 500.0 ;
% set secondary diameter
sec_diam = 890.0 ;
% secondary thickness
thick_sec = 139.7 ;
% Primary to secondary separation
m1_m2 = 6502.485 ;
% set diameter of hole in primary
hD = 304.8 ;
% back focal length fron primary vertex to screen
bfl = 2273.92 ;
% Distance secondary to screen 
% additional 500.0 added from focal point determined on axis, best 
% focus from rays_through(5).focal_point()
m2_scr = m1_m2 + bfl + 500.0 - 5.0 ;

% back surface of the circular  mirror diagonal of thickness thick_sec
mirror1 = Plane( [ dist_sec-thick_sec 0 0 ], sec_diam, { 'mirror' 'air' } ); % pay attention to the glass order here!
bench.append( mirror1 );

% parabolic mirror
mirror2 = Lens( [ dist_sec+m1_m2 0 0 ], [hD 1549], -30557.78, -1, { 'air' 'mirror' } ); % pay attention to the glass order here!
bench.append( mirror2 );

% front surface of the circular mirror secondary 
mirror3 = Plane( [ dist_sec 0 0 ], sec_diam, { 'mirror' 'air' } ); % pay attention to the glass order here!
bench.append( mirror3 );

% screen
screen = Screen( [ m2_scr 0 0 ], 200, 200, 4000, 4000 );
bench.append( screen );

% create collimated rays
% second vector [ 1 0 0 ] is direction as direction cosines
% ray bundle parallel to x-axis, optical axis as l_x = 1, m_y = n_z = 0
% 14.5 arcmin along y axis
l_x = 0.9999911;
m_y = 4.217867e-3;
n_z = 0.0;
% 14.5 arcmin at ~10 o'clock
l_x = 0.9999822 ;
m_y = 4.217867e-3 ;
n_z = m_y ;

% sanity check on direction cosines
dir_cos_sqrs = l_x^2 + m_y^2 + n_z^2;
dir_cosine_chk = abs(dir_cos_sqrs - 1)/1.0 ;
if dir_cosine_chk > 0.00001 
    error('Squares of Direction cosines must sum to 1.0 !!!')
end
% If error did not trip, continue

nrays = 500;
rays_in = Rays( nrays, 'collimated', [ 100 0 0 ], [ l_x m_y n_z ], 1600, 'hexagonal' );

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
bench.draw( rays_through, 'arrows', [], [ 3 0 3 3 3 ] );  % display everything, specify arrow length for each bench element

% get the screen image in high resolution
nrays = 10000;
rays_in = Rays( nrays, 'collimated', [ 100 0 0 ], [ l_x m_y n_z ], 1600, 'hexagonal' );
bench.trace( rays_in, 0 );
figure( 'Name', 'Image on the screen', 'NumberTitle', 'Off' );
imshow( screen.image, [] );
% Use xlim and ylim if only a subsection of screen is desired. 
% xlim([400,500]);
% ylim([450,550]);
axis on;
grid on;
colorbar;
xlabel('Y coordinate')
ylabel('Z coordinate')
title('Screen Image (X coordinate is focus position)')
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
