# mingze-gao.com
 
This repo contains the files for my personal site [mingze-gao.com](https://mingze-gao.com).

The site is built and deployed upon Git commit and push with the help of [GitHub Actions](https://docs.github.com/en/actions). I can therefore update the site anytime and anywhere.

## Details

This site is built with [mkdocs-material](https://github.com/squidfunk/mkdocs-material) insider version. 

- To get the insider version, please head to [Insiders - Material for MkDocs](https://squidfunk.github.io/mkdocs-material/insiders/).
- The free version works well too but the configuration is a slightly different.

`.github/workflows/ci.yml` describes the GitHub Actions taken to build/deploy the site on push.

To use the free version of [mkdocs-material](https://github.com/squidfunk/mkdocs-material), replace:

``` yaml
- run: pip install git+https://${{ secrets.GH_TOKEN }}@github.com/squidfunk/mkdocs-material-insiders.git
```

with:

``` yaml
- run: pip install mkdocs-material
```

You can follow the [guide](https://squidfunk.github.io/mkdocs-material/insiders/getting-started/#requirements) to set up the insider version.

The generated static site files are under the `gh-pages` branch. Remember to change the GitHub settings for the repo. Specifically, under the Pages setting tab, change the `source` to the root folder of the `gh-pages` branch.