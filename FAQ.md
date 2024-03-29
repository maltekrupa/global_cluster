# FAQ

If you have a question create an Issue or write [me
somewhere](https://nafn.de/contact/).

## How did I setup wireguard?

Using this project: [k4yt3x/wg-meshconf](https://github.com/k4yt3x/wg-meshconf).

It manages a CSV containing all involved nodes and can generate the config and
keys for all nodes. I then use ansible to move them into place and start the
tunnels.

## Why Wireguard instead of VPC peering/transit gateways?

In my professional life I deal a lot with these VendorOps solutions because most
companies want them but in my private life I try to learn the
technology/protocols behind them.

Initially I planned to run each VM on a different hoster somewhere in the world
but finding them, dealing/paying them and making sure they support FreeBSD was
taking too much time, so I went back to AWS.

## Why FreeBSD?

Let me start by saying: This is my opinion. You can have a different one. That's
fine. :)

Linux distributions took away the fun with Linux for me. Every new release meant
re-learning a lot of new things and breaking changes left and right.

Two years ago a friend recommended FreeBSD as an alternative. For a year now I'm
using it primarily on my servers. It's a very simple OS. It's capable, fast and
does what I need. The documentation/handbook is the best thing I've seen in IT
in the last years. I miss docker from time to time though.

But as with Linux, I wouldn't dare to run it on my notebook as a daily driver.

Keep in mind: This is my opinion. YMMV! :)

## Why packer?

The default AMIs for FreeBSD do a system upgrade on the first boot which takes
somewhere between five to ten minutes. This is too long to stay sane, so I
created a custom AMI that has this step already done.

Some FreeBSD people are currently making this situation better.

## Why not fly.io/gigaelixir?

I had a couple of things running on fly.io in the past and it was ok, but ... I
want to learn stuff that I can use whereever I go.

All these abstractions come at a cost. Once something doesn't work you have to
deal with a company. For me this feels like wasted time. Again, YMMV.

## Why no TLS on the site?

I'm lazy. The infrastructure work already took way more time than I'd like to
admit. Remember, it's a side project that will go away soon.

## What else is involved?

Each VM also runs HAProxy and a Grafana Agent.

Grafana is configured to use Grafana Cloud, but the metrics are rather useless
because there is barely any load on the VMs.

## How much does it cost to run this on AWS?

About 50 Euros per month.

## Oh my gosh those numbers. Are you famous?

No. Don't trust these numbers. I regularly ran load tests using
[wrk](https://github.com/wg/wrk).

I did this because my first attempts with this app resulted in a very slow web
site that could handle around 1.25 requests per second. You can read about it
[in the changelog](CHANGELOG.md).

I also wanted to see how traffic between the servers flows when one of them is
hit by a lot of traffic. Interesting stuff.
