From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 19 Dec 2002 20:19:18 +0000
Subject: Re: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805617@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Dec 2002 08:33:38 -0800, "Patil, Harish" <harish.patil@intel.com> said:

  Harish> I have a RHAS kernel compiled with *gcc3.2*. Using a script
  Harish> based on readelf/objdmp I found out that there are 7
  Harish> instances in this kernel where 'rlen' may be wrong. The
  Harish> invariant the script is looking for is this: Sum(rlen for
  Harish> various regions) = Number of slots in the code range.

  Harish> The script found following violations of the invariant:

  Harish> <ia64_trace_syscall>:
  Harish> <ia64_ret_from_clone>:
  Harish> <ia64_prepare_handle_unaligned>:
  Harish> <ia32_ret_from_clone>:
  Harish> <memset>:
  Harish> <memcpy>:

These are all handwritten assembly routines.  I think I see what's wrong:

 (a) for the first 4 routines, note how they all start with an empty
     prologue (e.g., PT_REGS_UNWIND_INFO(0)); these empty prologues
     seem to cause gas to not count the "nop"s at the beginning of the
     code. Or perhaps gas never counts the starting "nop"s and this is
     just one of the places where the first instruction cannot go into
     the first slot of a bundle.

 (b) for memcpy and memset, I suspect the ".align 32" directives are
     confusing gas

(a) is probably a bug in gas.  For (b), gas can't guarantee much
because (in general) it can't know the alignment of the first
instruction of a procedure (not beyond the minimum of 16 bytes).  We
should fix the assembly source here (use label_state/copy_state around
the .align directives, or get rid of them alltogether).  One thing we
could do in gas, however, is add a warning so that a programmer will
know when s/he accidentally uses a .align directive inside a region.

  Harish> code_range= 0xe000000004b18000-0xe000000004b182b0
  Harish>         lo =  4B18000  hi = 4B182B0
  Harish>         sum_rlen =  130 no_slots = 129
  Harish>             *******ERROR ***********
  Harish>             sum_rlen: 130  != no_slots:129

Do you know what code this is?  The addresses are not terribly useful
because they'll vary from one kernel to another.

Is your script fully automatic?  If so, perhaps we could add it to the
kernel sources and run it as part of "make check".  I'd love to have
better unwind-info checking tools.  Actually, it's even more important
to use such tools to verify the correctness of the user-level unwind
info.

Someone wants to volunteer to fix this stuff?

	--david

