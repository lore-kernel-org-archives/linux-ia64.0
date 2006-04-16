From: Paul Mackerras <paulus@samba.org>
Date: Sun, 16 Apr 2006 07:02:19 +0000
Subject: Re: [PATCH 00/05] robust per_cpu allocation for modules
Message-Id: <17473.60411.690686.714791@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1145049535.1336.128.camel@localhost.localdomain>
	<4440855A.7040203@yahoo.com.au>
	<Pine.LNX.4.58.0604151609340.11302@gandalf.stny.rr.com>
	<4441B02D.4000405@yahoo.com.au>
	<Pine.LNX.4.58.0604152323560.16853@gandalf.stny.rr.com>
In-Reply-To: <Pine.LNX.4.58.0604152323560.16853@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Martin Mares <mj@atrey.karlin.mff.cuni.cz>, bjornw@axis.com, schwidefsky@de.ibm.com, benedict.gaster@superh.com, lethal@linux-sh.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@tensilica.com>, Joe Taylor <joe@tensilica.com>, David Mosberger-Tang <davidm@hpl.hp.com>, rth@twiddle.net, spyro@f2s.com, starvik@axis.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, ralf@linux-mips.org, linux-mips@linux-mips.org, grundler@parisc-linux.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, davem@davemloft.net, rusty@rustcorp.com.au

Steven Rostedt writes:

> So now I'm asking for advice on some ideas that can be a work around to
> keep the robustness and speed.

Ideally, what I'd like to do on powerpc is to dedicate one register to
storing a per-cpu base address or offset, and be able to resolve the
offset at link time, so that per-cpu variable accesses just become a
register + offset memory access.  (For modules, "link time" would be
module load time.)

We *might* be able to use some of the infrastructure that was put into
gcc and binutils to support TLS (thread local storage) to achieve
this.  (See http://people.redhat.com/drepper/tls.pdf for some of the
details of that.)

Also, I've added Rusty Russell to the cc list, since he designed the
per-cpu variable stuff in the first place, and would be able to
explain the trade-offs that led to the PERCPU_ENOUGH_ROOM thing.  (I
think you're discovering them as you go, though. :)

Paul.
