From: "David S. Miller" <davem@redhat.com>
Date: Thu, 25 Apr 2002 01:00:23 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905525@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jesse Barnes <jbarnes@sgi.com>
   Date: Wed, 24 Apr 2002 18:01:59 -0700

   I fully understand and agree with that, and I don't propose adding the
   call just for the fun of it.  It's just that most of the time, it's
   easier software-wise to use the 64 bit consistent mappings if your
   device can support it (e.g. generic ia64, ia64/sn).
   
It isn't easier, in fact it's a lot harder.

The DMA api is confusing enough, and you want to add yet another
interface for device driver author Joe Blow to have to learn?

   I don't think the performance impact of those extra cycles would be
   measurable, but I'd be happy to see any numbers you might have to the
   contrary.
   
You already showed me the numbers.

Hardware folks don't make hardware so you can waste cycles, every
one counts.  I guess this is a fundamental disagreement in approach
between you and me.  So let's just agree to disagree.

You have to show me a significant advantage to add a completely new
API to the mix.  It has to be important enough that it is worth making
every driver author learn the new interface.

This basically boils down to the fact that it must do one of two
things:

1) It must make performance phenominally better.

   In the DAC consistent case, it actaully will decrease bus
   utilization slightly, we agree on this.

2) It must make some DMA performance optimization possible which
   currently is not possible at all.

   I do not believe this is the case.  You've tried to argue that
   SAC consistent memory is precious for mappings, and I've tried
   to show you that the consistent part of the mappings used by
   devices won't even show up on the radar.

We are at an impasse' and I really doubt this is going to change.
All you can do by arguing further is just make me type the same
things a few more times, and I'd like to avoid that, I type enough
already. :-)

