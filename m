From: Philip R Auld <pauld@egenera.com>
Date: Wed, 10 Nov 2004 15:53:38 +0000
Subject: Re: [PATCH] make INIT# handler call panic
Message-Id: <20041110155338.GA12366@vienna.egenera.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1099662943.913.180.camel@clarsen>
In-Reply-To: <1099662943.913.180.camel@clarsen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Rumor has it that on Mon, Nov 08, 2004 at 09:14:21PM +0900 Takao Indoh said:
> Hi,
> 
> On Fri, 05 Nov 2004 17:57:29 -0500, Cliff Larsen wrote:
> 
> >> I don't have an opinion about whether calling panic from
> >> init_handler_platform() is the right thing to do or not.
> >> Certainly it is a good place for some sort of hook for a
> >> debugger and/or crashdump.
> >
> >My major motivation was to get to a crashdump hook and get 
> >to restart, and panic does both, so I chose it.
> 
> IIRC, LKCD is invoked by panic_notifier_list in the panic(), so
> LKCD may work correctly. But diskdump/netdump may not. They
> are called via BUG(). For example, netdump is called from the following
> BUG().
> 

Calling BUG would also work, assuming the hooks are in the
BUG path. I'm not seeing that in 2.6.8 anyway.


> Normally BUG() invokes exception handler and dump function is called.
> But, I am not sure exception handler is correctly invoked from the INIT
> context.

This doesn't currently do much in ia64 as far as I can tell. It ends up 
in die via die_if_kernel, but that doesn't look like it will ever get to a 
machine restart, much less a crash dump or even a for(;;) loop. I may be 
missing something though. I'm pretty new to Itanium. 

In i386 there is panic_on_oops in die which can at least get to the 
panic call chain (as there used to be in ia64).

None of the dump stuff is in the stock kernels yet is it?

> 
> 
> >> My personal preference would be something like this:
> >>    1) dump register state (for all CPUs, not just the INIT monarch)
> >>       on the console
> >>    2) print backtraces (maybe just for currently-running tasks;
> >>       currently we do the task on the INIT monarch plus all other
> >>       non-running tasks, which is definitely non-optimal)
> >>    3) optional debugger/crashdump hook
> >>    4) call panic (maybe)
> >>    5) optional timeout, then reboot (if not calling panic)
> >> 
> >> Part 5 would be trivial and probably not *too* controversial.
> >> Part 1 is harder but extremely useful, and I think someone (Zoltan?)
> >> posted a start.  Part 2 should be simple given part 1.
> >
> >I'll see what I can do about most of these. Part 1 would be
> >difficult since the hardware/firmware we've currently got 
> >available makes both processors the monarch on INIT.
> 
> Even if crashdump hook is added into the init_handler, dump does not
> work correctly because of single INIT stack. Therefore Russ Anderson's
> patch which separates INIT stack is also indispensable.
> 

We are still mostly a working with 2.4 (rhel3 which has netdump_func hooks) 
and this all worked fine. A crashdump hook, a call to panic, or a call 
to BUG each worked.

I doesn't look like anything but the crashdump hook can work in stock
2.6.8 since there are no dump routine calls in the panic or die paths.

Cheers,

Phil

> Regards,
> Takao Indoh

-- 
Philip R. Auld, Ph.D.  	        	       Egenera, Inc.    
Software Architect                            165 Forest St.
(508) 858-2628                            Marlboro, MA 01752
