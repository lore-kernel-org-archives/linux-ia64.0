From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Aug 2007 20:36:27 +0000
Subject: RE: [PATCH] disable irq's and check need_resched before safe_halt
Message-Id: <617E1C2C70743745A92448908E030B2A0229F474@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070807134932.GA30447@sgi.com>
In-Reply-To: <20070807134932.GA30447@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Yeah, I think the TIF flag was the key in fixing the resched IPI
> notification.  The change in default_idle() is an optimization.
>
> I'm horrified to see the same code coming back: doing interrupt
> enable/disable in the most inner while loop.  Disable interrupt is
> just crude, but I suppose that's the only way to resolve the race
> condition?  Looking at other arch like x86_64, it is also doing the
> same thing.

Yup.  x86 does pretty much the same thing.

I had the perf. team run the problem benchmarks (netperf and volanomark)
with this patch applied ... and they saw no performance difference.

The patch is bundled to go in with the next batch that I send
to Linus.

-Tony
