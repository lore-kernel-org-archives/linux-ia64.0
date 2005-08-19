From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 19 Aug 2005 23:13:38 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <17158.26530.839339.381688@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:

Stephane> Hello, So I spent some time investigating the booloader
Stephane> problem with ski and gcc-4.0. I think I found the source of
Stephane> the problem. The fix from Ian is not solving the problem it
Stephane> is simply masking it.

Stephane> The real problem for the stat structure is that it gets
Stephane> overwritten by the mem[] array and not disk_req. I added
Stephane> some debug printf to the simulator and looked at the symbol
Stephane> table for the bootloader. The mem[] array is static.
Stephane> The disk_stat is allocated on the stack, I think. Now
Stephane> with gcc-4.0 the mem[] array overlaps the disk_stat!

Take a look at this code from boot_head.S:

    
    .bss
    .align 16
stack_mem:
    .skip 16834

GLOBAL_ENTRY(_start)
	.prologue
	.save rp, r0
	.body
	movl gp = __gp
	movl sp = stack_mem
	bsw.1
	br.call.sptk.many rp=start_bootloader
END(_start)

Doesn't the stack grow downwards on IA64? Shouldn't that be something
like:

	.bss
	.align 16
rbs_mem:
	skip 18384-16
stack_mem:
	skip 16

????

I can't run ski at present to check it (it segfaults immediately)

Peter C
