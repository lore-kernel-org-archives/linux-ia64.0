From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 05 Nov 2004 22:04:29 +0000
Subject: Re: [PATCH] make INIT# handler call panic
Message-Id: <200411051504.29679.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1099662943.913.180.camel@clarsen>
In-Reply-To: <1099662943.913.180.camel@clarsen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 05 November 2004 2:04 pm, Cliff Larsen wrote:
> I've been working with 2.4 so I thought it would be appropriate
> to submit the patch with its latest version. I've not gotten to 
> 2.6 yet. I have looked at 2.6 sources and essentially the same 
> patch would apply. What do you think of the concept of the patch
> and its utility in 2.6?

Yeah, I'm sure it would apply easily to 2.6.  Sorry, I guess I
was just being lazy because I haven't paid much attention to
the MCA/INIT path recently.  Some of the folks who have will
probably jump in.

My $0.02 is that it *is* annoying that we just hang after printing
the INIT register state and backtraces.  However, I wonder if we
could just leverage the existing panic_timeout (set by "panic=")
so we don't need a new parameter.

I don't have an opinion about whether calling panic from
init_handler_platform() is the right thing to do or not.
Certainly it is a good place for some sort of hook for a
debugger and/or crashdump.

My personal preference would be something like this:
   1) dump register state (for all CPUs, not just the INIT monarch)
      on the console
   2) print backtraces (maybe just for currently-running tasks;
      currently we do the task on the INIT monarch plus all other
      non-running tasks, which is definitely non-optimal)
   3) optional debugger/crashdump hook
   4) call panic (maybe)
   5) optional timeout, then reboot (if not calling panic)

Part 5 would be trivial and probably not *too* controversial.
Part 1 is harder but extremely useful, and I think someone (Zoltan?)
posted a start.  Part 2 should be simple given part 1.
