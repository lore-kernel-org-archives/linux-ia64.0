From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Jan 2005 05:32:49 +0000
Subject: Re: About intercepting linux system call
Message-Id: <16888.32001.695169.138637@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <b3b26beb05012620543066d40@mail.gmail.com>
In-Reply-To: <b3b26beb05012620543066d40@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi JinShan,

>>>>> On Thu, 27 Jan 2005 12:54:40 +0800, JinShan Xiong <jinshan.xiong@gmail.com> said:

  JinShan> Hi all, i just want to intercept ia64 linux kernel's
  JinShan> syscall entry. I remapped the physical page contained
  JinShan> syscall table to a new read/write page in a vmalloc
  JinShan> region(0xa0000...) since ia64 linux kernel has been linked
  JinShan> the syscall table into a .rodata section, Yes, I can modify
  JinShan> the syscall entry now, but the kernel crashed after the
  JinShan> kernel entered into my own new function.

  JinShan> I run my test code on a Hp-ia64 machine with redhat AS-2.1e
  JinShan> installed, and the kernel is 2.4.18-e.47smp.

  JinShan> I am not familiar with ia64 architecture, please help me,
  JinShan> thanks.

Hi JinShan,

There is no need to copy the syscall table to a writable area.  On
ia64, the kernel memory is writable (for the kernel) by default.  I
think the problem in your code is due to the gp register not being
setup properly before calling into the module.  Each module gets its
own global-offset-table (GOT) so the gp needs to be loaded up before
calling any of the module's C function.  However, the kernel assumes
that all system calls are implemented in the kernel proper, so it
bypasses the gp-loading that would normally happen when calling
through a function-pointer.

This can be fixed with a little stub which takes care of saving the
old gp-value, loading the modules gp, calling the real function and,
upon return, restoring the original gp-value.

I think something like this might work:

	.proc new_time_stub
new_time_stub:
	.prologue
	.regstk 2, 3, 2, 0
	.save ar.pfs, loc1
	alloc loc1 = ar.pfs, 2, 3, 2, 0
	movl r2 = @gprel(zero);;
	.save rp, loc0
	mov loc0 = rp
	mov loc2 = gp
	sub gp = r0, r2
	mov out0 = in0
	mov out1 = in1
	br.call.sptk.many rp = new_time
1:	mov rp = loc0
	mov ar.pfs = loc1
	mov gp = loc2
	br.ret.sptk.many rp
	.endp

Here, "zero" needs to be a symbol that the linker resolves to 0.  You
can define "zero" either via a linker script or by passing the linker
the option "--defsym zero=0".  It may not be the most elegant way to
get the GP value, but it ought to work both on 2.4 and 2.6 (which use
different module loaders).

Having said that, two caveats:

 - In 2.6, sys_call_table is no longer exported, so your code can't
   work (and that's intentional, see below).

 - Kernel developers generally frown on modules that try to intercept
   syscalls.  For one thing, it's potentially racy in an SMP
   environment and for another, it's questionable whether it's even
   legal to do so, at least if the module is proprietary (not offering
   a legal opinion here, just raising a potential red flag).

On a related topic, you may find it easier to develop such code with
the Ski simulator [1].  It's very easy to setup and would let you
single-step through the code in question, so you can see exactly
what's going on.

	--david

[1] http://www.hpl.hp.com/research/linux/ski/
