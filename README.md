# Vagrant config and Chef cookbooks for DarkPAN deployment

1. Install http://vagrantup.com/
2. Clone this repo
2. Run `vagrant up` (this can take a while)
4. Point your browser to `http://localhost:5001`

## What's inside

* private MetaCPAN instance
* Pinto repository and `pintod`

## How to upload

Use [Pinto](https://metacpan.org/module/Pinto::Manual::Introduction):

```
pinto --root http://darkpan.yandex-team.ru:6000 add ./Foo-1.0.tar.gz
```

## How to install

```
cpanm --mirror-only --mirror http://darkpan.yandex-team.ru:6000/darkpan Foo
```
