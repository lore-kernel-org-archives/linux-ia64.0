From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 18 Nov 2003 16:42:02 +0000
Subject: Re: [RFC][PATCH] linux-2.4.23-pre9_ia64-cyclone_A0
Message-Id: <marc-linux-ia64-106917632227904@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106911773604958@msgid-missing>
In-Reply-To: <marc-linux-ia64-106911773604958@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 17 November 2003 6:08 pm, john stultz wrote:
> On Mon, 2003-11-17 at 17:02, john stultz wrote:
> > On Mon, 2003-11-17 at 16:23, Bjorn Helgaas wrote:
> > > SGI uses a similar design in 2.4, but apparently there are some
> > > issues with it:
> > > 	http://www.gelato.unsw.edu.au/linux-ia64/0310/6973.html
> > > 
> > > I'd like to see those issues resolved and the Cyclone support
> > > put into the same framework as the SGI work.
> > 
> > Hmmm. I think I've grasped the issue there. It seems the problem is not
> > calculating the equivalent of delay_at_last_interrupt found in the i386
> > time code. I'll see if I cannot come up with something similar.
> 
> Actually, on second though, I don't believe this is necessary as every
> tick we increment last_tick_cyclone by one tick, rather then zeroing it
> out. In that way, even if the interrupt is delayed we don't lose time. 
> 
> I may be missing some subtlety, but I think the point made above was
> considered in my patch. 

OK, that's good.

Apart from that correctness question, I have some concerns about
how the code is structured.  I don't think I've seen the actual
SGI patch either, but based on John Hawkes' email (URL above),
the hook looks something like:

+               if (ia64_platform_timer_interrupt)
+                       (*ia64_platform_timer_interrupt)();

That's far better than adding stuff like this:

+       if(use_cyclone)
+               return do_gettimeoffset_cyclone() + lost * (1000000 / HZ);

because the former is much more generic.

I also don't like adding asm-ia64/cyclone.c and ia64/kernel/cyclone.c.
Those files are machine-specific and don't belong in the generic ia64
area.  (In fact, they look functionally identical to the i386 code;
could this all be consolidated in something under drivers/ and shared?)

Bjorn

