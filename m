From: Piet/Pete Delaney <piet@sgi.com>
Date: Thu, 03 Jan 2002 01:39:00 +0000
Subject: [Linux-ia64] Re: [lkcd-general] stack overflows and lkcd (Dynamicly mapping the Red Zone and Switchi
Message-Id: <marc-linux-ia64-105590698805730@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 02, 2002 at 04:22:58PM -0800, Castor Fu wrote:
> I noticed that LKCD uses a fair amount of stack space in dump_kernel_write().
> 
> The array of longs for the block sizes, b[], is about 4K which is enough that
> it's not too hard to blow the stack, resulting in a lost dump.
> 
> Also, in general, the crash dumper isn't going to work if the stack has
> already been overrun.  We might want to have an alternate stack for that.

This was what I was discussing with  Richard Moore:

	Date: Tue, 11 Dec 2001 10:31:00 -0800
	Date: Tue, 11 Dec 2001 17:12:03 -0800

We not only have to have an alternate stack but need to save all of the
registers for the CPU(s) that get a kernel stack overflow or other MMU problems.
With MMU problems it's possible for many CPU to fail at the same time.

In Solaris 2.9 I allocated an extra stack for each CPU as well as an extra
page to hot map to the red zone so that the stack could be flushed and
looked at with the crash analyzer (lkcd for example). The kernel couldn't 
run with the extra page but the panic code could produce a nice stack trace. 
It made stack analysis a lot easier. 

I also saved the CPU registers using only physical addresses since the MMU 
could be messed up. In the infrequent case of a MMU failure you can't save 
the core dump but you can print the stack traces, registers for the CPU's,
look at the memory with the kernel debugger and possibly do a few MMU 
experiments.

Most likely the lcrash/lkcd dump_header_asm_t registers should be extracted 
from the the regster save area for each processor.

-piet





