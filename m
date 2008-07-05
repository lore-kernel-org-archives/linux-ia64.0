From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 05 Jul 2008 17:56:54 +0000
Subject: Re: the printk problem
Message-Id: <alpine.LFD.1.10.0807051045520.2815@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080705125230.GA20166@damson.getinternet.no>
In-Reply-To: <20080705125230.GA20166@damson.getinternet.no>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Jan Engelhardt <jengelh@medozas.de>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew@wil.cx>, Peter Anvin <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org



On Sat, 5 Jul 2008, Vegard Nossum wrote:

> On Sat, Jul 5, 2008 at 1:33 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
> >
> > On Saturday 2008-07-05 00:01, Andrew Morton wrote:
> >>
> >>We don't know how much interest there would be in churning NIPQUAD from
> >>the net guys.  Interestingly, there's also %C (wint_t) which is a
> >>32-bit quantity.  So we could just go and say "%C prints an ipv4
> >>address" and be done with it.  But there's no way of doing that for
> >>ipv6 addresses so things would become asymmetrical there.
> >
> >        struct in6_addr src;
> >        printk("Source address: %p{ipv6}\n", &src);
> >
> > How about %p{feature}?

No.

I _expressly_ chose '%p[alphanumeric]*' because it's basically 
totally insane to have that in a *real* printk() string: the end result 
would be totally unreadable.

In contrast, '%p[specialchar]' is not unreadable, and in fact we have lots 
of those already in the kernel. In fact, there are 40 occurrences of '%p{' 
in the kernel, just grep for it (especially the AFS code seems to be very 
happy to use that kind of printout in its debug statements).

So it makes perfect sense to have a _real_ printk string that says

	"BUG: Dentry %p{i=%lx,n=%s}"

where we have that '%p{...' sequence: the end result is easily parseable. 
In contrast, anybody who uses '%pS' or something like that and expects a 
pointer name to be immediately followed by teh letter 'S' is simply 
insane, because the end result is an unreadable mess.

> (It's hard on the stack, yes, I know. We should fix kallsyms.)

Not just that, but it's broken when KALLSYMS is disabled. Look at what 
sprint_symbol() becomes.

The patch I already sent out is about a million times better, because it 
avoids all these issues, and knows about subtle issues like the difference 
between a direct pointer and a pointer to a function descriptor. 

		Linus
