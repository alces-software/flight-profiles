# Alces Flight Profiles

Profiles for use with [Alces Clusterware](https://github.com/alces-software/clusterware) that provide hooks for customization of the behaviour of a cluster when events occur.

## Installation

The scripts maintained within this repository operate in conjunction with the Alces Clusterware `cluster-customizer` handler.  Installation of Clusterware handlers occurs as part of the Alces Clusterware installation.  Refer to the Alces Clusterware documentation for details of how to enable, disable and manage handlers.

When an Alces Flight Compute instance undergoes initialization, these profiles are retrieved from Amazon S3 allowing on-the-fly, instance type-specific and organization-specific customization capabilities, as well as allowing various features to be selectably enabled on a specific instance or instances.

## Scripts

The `scripts` directory contains scripts that perform various functions depending on the feature being enabled:

### `nvidia-support`

Orchestrate the installation and configuration of NVIDIA GPU support.

## Profiles

The `profiles` directory contains predefined links to scripts that support either a specific instance type (e.g. `g2.2xlarge`, `c4.8xlarge` etc.) or provide a particular feature (e.g. `sge-scheduler`, `slurm-scheduler`).

## Contributing

Fork the project. Make your feature addition or bug fix. Send a pull request. Bonus points for topic branches.

## Copyright and License

Creative Commons Attribution-ShareAlike 4.0 License, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2016 Alces Software Ltd.

You should have received a copy of the license along with this work.  If not, see <http://creativecommons.org/licenses/by-sa/4.0/>.

![Creative Commons License](https://i.creativecommons.org/l/by-sa/4.0/88x31.png)

Alces Flight Profiles by Alces Software Ltd is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

Based on a work at <https://github.com/alces-software/flight-profiles>.

Alces Flight Profiles is made available under a dual licensing model whereby use of the package in projects that are licensed so as to be compatible with the Creative Commons Attribution-ShareAlike 4.0 International License may use the package under the terms of that license. However, if these terms are incompatible with your planned use of this package, alternative license terms are available from Alces Software Ltd - please direct inquiries about licensing to [licensing@alces-software.com](mailto:licensing@alces-software.com).
