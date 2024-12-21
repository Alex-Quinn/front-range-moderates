# Front Range Moderates

[![Built with Almace Scaffolding](https://d349cztnlupsuf.cloudfront.net/amsf-badge.svg)](https://sparanoid.com/lab/amsf/)

-----

## Local Development

[Full AMSF docs here](https://sparanoid.com/lab/amsf/getting-started.html)

TLDR:
```
bundle install
yarn install
grunt init
grunt serve
# Visit http://0.0.0.0:4321/
```

All development is done on the `master` branch. Production tracks the `cf-pages` branch.

## Deployment

Deployed via [Cloudfront Pages](https://developers.cloudflare.com/pages/). [Deployment instructions here](https://sparanoid.com/lab/amsf/deployment-methods.html).

Cloudfront Pages tracks the `cf-pages` branch as the production branch. Deployments are triggered automatically upon pushing to the `cf-pages` branch.

To deploy:
```
# ...make changes on `master` branch
git checkout cf-pages
git merge master
git push
```
