# Vagrant config and Chef cookbooks for DarkPAN+MetaCPAN deployment

1. Install http://vagrantup.com/
2. Clone this repo
2. Run `vagrant up` (this can take a while)
4. Point your browser to `http://localhost:5001`

Inject new modules to the darkpan repo using `./tmp/inject_module.pl PATH_TO_TAR_GZ` (this script is the work-in-progress).
