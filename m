From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 29 May 2003 03:53:13 +0000
Subject: Re: [Linux-ia64] High fpu register corruption (PATCH)
Message-Id: <marc-linux-ia64-105590723706065@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705679@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705679@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 22 May 2003 3:55 pm, Mallick, Asit K wrote:
> Attached is a patch to fix the high FPU corruption (thanks to Andreas
> and Chris). This patch also unifies the FPU save/restore for SMP and UP
> and also fixes another problem with FPH save/restore path due to an
> unaligned fault.

I'm comparing 2.4 (including your patch) and David's current
2.5 BK tree.  I'd like to keep them as close as possible, but
I see several clearly gratuitous differences (like whitespace)
and some that aren't obvious to me.

arch/ia64/kernel/ptrace.c:
	2.4 calls ia64_drop_fpu() from ia64_sync_fph().
	2.5 calls ia64_drop_fpu() from ia64_flush_fph().
	Is there a reason for the difference?

arch/ia64/kernel/setup.c:
	cpu_init(): 2.4 added ia64_set_kr() and removed
	ia64_set_fpu_owner(); 2.5 doesn't have this change.
	This looks like at least partly a bug in 2.5 --
	ia64_set_fpu_owner is called under "#ifndef CONFIG_SMP"
	but not defined anywhere.

arch/ia64/kernel/signal.c:
	restore_sigcontext() changes look equivalent, but have
	gratuitous differences from 2.5 (reversed sense of test,
	comment)

arch/ia64/kernel/traps.c:
	disabled_fph_fault(): 2.4 uses ia64_is_local_fpu_owner();
	2.5 uses "fpu_owner = current".  Is there a reason for
	this?

	Also gratuitous whitespace differences.

include/asm-ia64/processor.h:
	ia64_is_local_fpu_owner(), ia64_set_local_fpu_owner():
	these look functionally equivalent in 2.4 and 2.5.
	Can they be made identical?

include/asm-ia64/system.h:
	IA64_HAS_EXTRA_STATE() and switch_to() appear to be
	identical in 2.4 and 2.5 except for whitespace changes.
	Can they be made identical?

Any insight would be appreciated!

Bjorn


