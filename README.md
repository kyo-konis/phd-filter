# name
phd-filter

## Overview
-Probability Hypothesis Density filter  
-This is the tracking algorithm for unknown multiple targets with false detection and occasional non-detection.

## Requirement
- windows 11
- GNU Octave 9.4.0

## Usage
1.Make an instance of "phdClass."
1.Set the tracking parameters on instance's property.
1.Set the initial "Gaussian components" on instance's property.
1.Set the input detection and time of now time frame on instance's property.
1.Execute filter by call the method "phdClass.exe()."
1.Get the output track of now time frame from instance's property
* About the detail of the tracking parameters and the Gaussian components, read the Ba-Nu Vo's paper on the reference.

## Features
-This is an tracking algorithm for 2D or 3D detection data using constant velocity model.
-This is the "Gaussian Mixture" type or "Kalman Filter" type PHD-filter. ("particle filter" Type or "nonlinear filter" type is not implemented.)
-The function of adaptive birth intensity has not been implemented. Set the initial Gaussian components (tracks' information) manually.

## Reference
> The Gaussian Mixture Probability Hypothesis Density Filter
> B.-N. Vo and W.-K. Ma
> IEEE Trans. on Signal Processing vol.54, Issue.11, pp.4091-4104, Nov. 2006
[https://ieeexplore.ieee.org/document/1710358](https://ieeexplore.ieee.org/document/1710358)

## Author
kyo-konis
contact information: undisclosed

## Licence
[cc0](https://creativecommons.org/publicdomain/zero/1.0/)
