From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 24 Feb 2005 07:39:51 +0000
Subject: Re: Allow to change SD_NODES_PER_DOMAIN at configuration or boot
Message-Id: <1109230791.5177.104.camel@npiggin-nld.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <42138013.3060909@bull.net>
In-Reply-To: <42138013.3060909@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-02-16 at 17:24 -0800, Jesse Barnes wrote:
> On Wednesday, February 16, 2005 5:07 pm, Luck, Tony wrote:
> > Summary: I like the command-line settable value.  But the CONFIG
> > option still looks like it does the wrong thing as often as it helps.
> > The command line option needs to add some text to kernel-parameters.txt
> > to explain what this does, and how to pick the right value.
> 
> I completely agree and like the idea of a tunable too.  I'm not sure what the 
> default should be though--I don't think 6 makes much sense, but 4, as you 
> said, is capable of causing harm...  I guess we should just pick something.
> 

To all those looking at scheduler tuning - I have posted my
scheduler patchset to LKML, which should address various issues
with SMT, CMP, NUMA, excessive task movement between CPUs,
nodes, etc. However it is likely to be in a poor state of tune
for some workloads.

I hope Andrew will pick it up in -mm soon, but I can provide a
rollup against 2.6 if anyone is interested. I don't expect it to
be merged until after 2.6.12 at the earliest, but I hope that
anyone doing tuning can target this version, because it will
otherwise invalidate your results if I am able to get it merged.

Please ask, and I will be more than willing to try to help tuning
or solving any problems and regressions.

Nick


http://mobile.yahoo.com.au - Yahoo! Mobile
- Check & compose your email via SMS on your Telstra or Vodafone mobile.
