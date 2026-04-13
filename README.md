# Radial directionality kymograph of cell displacements (applicable to anz vector field)

This repository contains an minimum version of the code used to calculate the directionality of cell displacemts calculated over an entire image with respect to the radial direction e.x. cell move towards/outwards a central point. 

## Structure of the code

1. The code first read a .txt file with position and vector information of the form [X Y U V] in cartesian coordinates, where X: positon in X direction, Y: position in Y direction, U: horizontal component of vector, V: vertical component of vector. For this example the file "HM1_f_0036.txt" is provided. The coordinate system is then transformed from cartesian to polar coordinates centered in the middle of the iamge (e.x. the center of vector field).
2. Radial directionality is obtained by calculating vector magnitude in their correspondent radial angle for each vector over the entire image (e.x. vector field). In this case, positive values indicate displacement towards the center of the image, while negative values indicate displacements away from the center of the image.
3. The mean radial direction as a function of radial distance is calculated by averaging the magnitude of all vectors that lie on the same radial distance from center (e.x. circle of arbitrary radius).
4. A full kymograph is constructed by stacking successive radial direction vectors. The file "Kymograph.mat" contains an example matrix of dimensions: [Radial_distance Time Radial_directionality].
