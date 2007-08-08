From: Dimitri Sivanich <sivanich@sgi.com>
Date: Wed, 08 Aug 2007 15:01:36 +0000
Subject: Re: [PATCH] disable irq's and check need_resched before safe_halt
Message-Id: <20070808150136.GB22884@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070807134932.GA30447@sgi.com>
In-Reply-To: <20070807134932.GA30447@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 07, 2007 at 02:26:16PM -0700, Ken Chen wrote:
> I'm horrified to see the same code coming back: doing interrupt
> enable/disable in the most inner while loop.  Disable interrupt is
> just crude, but I suppose that's the only way to resolve the race
> condition?  Looking at other arch like x86_64, it is also doing the
> same thing.

If anyone can suggest a better alternative to fix this race condition,
I'd certainly consider it.

I suppose one alternative might be to move the local_irq_enable()
down into the default_idle loop so that we don't have to enable and
disable irq's the first time through if pal_halt will be called.
