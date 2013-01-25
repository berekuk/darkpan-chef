# Vagrant config and Chef cookbooks for DarkPAN deployment

1. Install http://vagrantup.com/
2. Clone this repo
2. Run `vagrant up` (this can take a while)
4. Point your browser to `http://localhost:5001`

## What's inside

* private MetaCPAN instance
* Pinto repository and `pintod`

## How to upload a module

Use [Pinto](https://metacpan.org/module/Pinto::Manual::Introduction):

```
pinto --root http://darkpan.yandex-team.ru:6000 add ./Foo-1.0.tar.gz
```

## How to install a module

```
cpanm --mirror-only --mirror http://darkpan.yandex-team.ru:6000/darkpan Foo
```

## How to deploy this code without Vagrant

You'll need a fresh Ubuntu 12.04 system.

1. Install chef:

```
apt-get install git build-essential autoconf zlib1g-dev libssl-dev \
    libreadline-dev libyaml-dev libcurl4-openssl-dev curl python-software-properties \
        ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1
gem install chef ruby-shadow --no-ri --no-rdoc
```

2. Fetch the cookbooks:

```
git clone git://github.com/berekuk/darkpan-chef.git
```

3. Configure server name in `solo/solo.json`. It should be something like this:
```
{
    "run_list": [ "recipe[darkpan::default]" ],
    "server": "darkpan.your-company-name.com"
}
```

4. Deploy the cookbooks:
```
cd darkpan-chef
./bin/solo-install.sh
```

**TODO: simplify this instruction by using knife-solo**

Note: pinto doesn't support `00whois.xml` file, so metacpan can't index authors info. This means that all `/author/LOGIN` pages won't work.
To make them work, write the `/opt/pinto/darkpan/authors/id/authors/00whois.xml` file manually (or implement a script which generates it).
