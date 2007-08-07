From: "Ken Chen" <kenchen@google.com>
Date: Tue, 07 Aug 2007 21:26:16 +0000
Subject: Re: [PATCH] disable irq's and check need_resched before safe_halt
Message-Id: <b040c32a0708071426g3b42dc84oa2209a64c3dc33d3@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070807134932.GA30447@sgi.com>
In-Reply-To: <20070807134932.GA30447@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 8/7/07, Luck, Tony <tony.luck@intel.com> wrote:
> This looks like it re-introduces code that Ken Chen backed out
> about two years ago.  Here's Ken's commit that explains what
> broke last time we made the idle loop look like this.  Now
> that code was wider ranging ... messing with TIF bits too,
> so maybe this is different this time?

Yeah, I think the TIF flag was the key in fixing the resched IPI
notification.  The change in default_idle() is an optimization.

I'm horrified to see the same code coming back: doing interrupt
enable/disable in the most inner while loop.  Disable interrupt is
just crude, but I suppose that's the only way to resolve the race
condition?  Looking at other arch like x86_64, it is also doing the
same thing.

- Ken
