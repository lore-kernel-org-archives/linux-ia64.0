From: Cliff Larsen <clarsen@egenera.com>
Date: Fri, 05 Nov 2004 22:57:29 +0000
Subject: Re: [PATCH] make INIT# handler call panic
Message-Id: <1099695448.913.242.camel@clarsen>
List-Id: <linux-ia64.vger.kernel.org>
References: <1099662943.913.180.camel@clarsen>
In-Reply-To: <1099662943.913.180.camel@clarsen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-11-05 at 17:04, Bjorn Helgaas wrote:
> My $0.02 is that it *is* annoying that we just hang after printing
> the INIT register state and backtraces.  However, I wonder if we
> could just leverage the existing panic_timeout (set by "panic=")
> so we don't need a new parameter.

I'm fine with that.

> I don't have an opinion about whether calling panic from
> init_handler_platform() is the right thing to do or not.
> Certainly it is a good place for some sort of hook for a
> debugger and/or crashdump.

My major motivation was to get to a crashdump hook and get 
to restart, and panic does both, so I chose it.

> My personal preference would be something like this:
>    1) dump register state (for all CPUs, not just the INIT monarch)
>       on the console
>    2) print backtraces (maybe just for currently-running tasks;
>       currently we do the task on the INIT monarch plus all other
>       non-running tasks, which is definitely non-optimal)
>    3) optional debugger/crashdump hook
>    4) call panic (maybe)
>    5) optional timeout, then reboot (if not calling panic)
> 
> Part 5 would be trivial and probably not *too* controversial.
> Part 1 is harder but extremely useful, and I think someone (Zoltan?)
> posted a start.  Part 2 should be simple given part 1.

I'll see what I can do about most of these. Part 1 would be
difficult since the hardware/firmware we've currently got 
available makes both processors the monarch on INIT.

Thanks for your feedback,
   Cliff

