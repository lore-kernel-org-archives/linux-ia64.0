From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 15 Jun 2004 13:12:41 +0000
Subject: Re: [PATCH] early console registration
Message-Id: <200406150912.41293.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405141425.59867.jbarnes@engr.sgi.com>
In-Reply-To: <200405141425.59867.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, June 14, 2004 6:27 pm, Bjorn Helgaas wrote:
> On Thursday 03 June 2004 3:49 pm, Jesse Barnes wrote:
> > Allow consoles to be registered early if they support doing output very
> > early in the boot process.  Consoles that allow this are subject to the
> > limitations outlined in the comments for the early_console_setup routine.
>
> (See original mail with patch here:
>     http://www.gelato.unsw.edu.au/linux-ia64/0406/9894.html)
>
> I'm still a little uneasy about setting cpu_online for CPU 0 so early.
> What if somebody comes along in the future and assumes the original
> semantics for cpu_online(0)?
>
> As another possibility, the following is a little more intrusive to
> printk.c, but also a little more explicit about what we're doing
> (untested).

Yeah, that's fine.  In fact, I've tested something similar and sent it to 
Andrew, but he came back and asked why not just set CPU 0 online early?  And 
given that CPU 0 is 'online' as soon as the kernel starts executing head.S, 
it seems like it *should* keep working, and we should probably keep it that 
way.

But either way is fine with me, so long as it gets upstream somehow.

Jesse
