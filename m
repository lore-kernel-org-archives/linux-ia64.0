From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 03 Jul 2002 16:33:35 +0000
Subject: [Linux-ia64] RE: kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905732@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Xavier,
Wondering if you can extract the test cases out of your test suite and send
to me?  The first one is intended not to expand the exception marcro due to
instruction bundling issue.  The exception handler suppose to catch the
fault.  I would like to see a test case that make it fail.  Thanks.

- Ken


-----Original Message-----
From: Xavier Bru [mailto:Xavier.Bru@bull.net]
Sent: Wednesday, July 03, 2002 6:28 AM
To: davidm@hpl.hp.com; Chen, Kenneth W
Cc: linux-ia64@linuxia64.org; Jacky.Malcles@bull.net
Subject: Re: kernel update (relative to 2.4.18)


David, Ken

Thanks for the patch that fixed this one :-)
unfortunately, we have other problems with the Itanium-2 based new memcopy
routines, and new Ooops running the ltp test suite (test system calls
with wrong arguments :-).
I identified problems due to missing static exception handler
definitions. A potential patch could be:

--- l.ref/arch/ia64/lib/memcpy_mck.S	Tue Jun 25 11:52:22 2002
+++ l/arch/ia64/lib/memcpy_mck.S	Wed Jul  3 09:21:15 2002
@@ -178,7 +178,7 @@
 	and	r21=-8,tmp
 	;;
 EX(.ex_handler, (p8)	ld8	t3=[src1])
-EK(.ex_handler, (p6)	st8	[dst0]=t1)	// store byte 1
+EX(.ex_handler, (p6)	st8	[dst0]=t1)	// store byte 1 
 	and	in2=7,tmp	// remaining length
 EX(.ex_handler, (p7)	st8	[dst1]=t2,8)	// store byte 2
 	add	src0=src0,r21	// setting up src pointer
@@ -215,7 +215,7 @@
 	// same as .line_copy loop, but with all predicated-off instructions
removed:
 .prefetch_loop:
 EX(.ex_handler_lcpy, (p[A])	ld8 v[A] = [src_pre_mem], 128)		//
M0
-EK(.ex_handler_lcpy, (p[B])	st8 [dst_pre_mem] = v[B], 128)		//
M2
+EX(.ex_handler_lcpy, (p[B])	st8 [dst_pre_mem] = v[B], 128)		//
M2 
 	br.ctop.sptk .prefetch_loop
 	;;
 	cmp.eq p16, p0 = r0, r0			// reset p16 to 1

But this seems not sufficient: we also are facing recursive calls to
__copy_user due to exeception management when running the
ex_handler_short path.

Herafter some traces:

Problem 1 (missing EX handler, fixed by patch).
-----------------------------------------------
Entering kdb (current=0xe000000012df8000, pid 2742) on processor 0 Oops:
<NULL>
due to oops @ 0xe00000000489d1a1
 psr: 0x0000121008026018   ifs: 0x800000000000cc18    ip: 0xe00000000489d1a0

unat: 0x0000000000000000   pfs: 0x000000000000038a   rsc: 0x0000000000000003

rnat: 0x0000000000000000  bsps: 0x0000000000000000    pr: 0x00000000000105e9

ldrs: 0x0000000000000000   ccv: 0x0000000000000000  fpsr: 0x0009804c0270033f

  b0: 0xe000000004425a40    b6: 0xe000000004401370    b7: 0x0000000000000000

  r1: 0xe000000004e50450    r2: 0xe000000012dffec8    r3: 0xe000000012dffed8

  r8: 0x0000000000000000    r9: 0xffffffffffffffff   r10: 0x0000000000000000

 r11: 0x00000000000005e9   r12: 0xe000000012dffd50   r13: 0xe000000012df8000

 r14: 0x60000fffff7fb510   r15: 0xe000000012dffec8   r16: 0x0000000000000018

 r17: 0x60000fffff7fb510   r18: 0x60000fffff7fb518   r19: 0xe000000012dfff48

 r20: 0x60000fffff7fb590   r21: 0x0000000000000018   r22: 0x60000fffff7fb4a8

 r23: 0x600000000000f458   r24: 0xc000000000000692   r25: 0x60000fffff7fdb50

 r26: 0xfffffffffffffff2   r27: 0x60000fffff7fb500   r28: 0x0000000000000000

 r29: 0x0000000000000000   r30: 0x0000000000000018   r31: 0x000000000000038a

&regs = e000000012dffbc0
[0]kdb> bt
0xe00000000489d1a0 __copy_user+0x160
        args (0x60000fffff7fb510, 0xe000000012dffec8, 0x18, 0x80000000f,
0x80200000000)
        kernel .text 0xe000000004400000 0xe00000000489d040
0xe00000000489d940
0xe000000004425a40 setup_sigcontext+0x320
        args (0x60000fffff7fb440, 0x60000fffff7fb4a0, 0xe000000012dffe60,
0xfffffffffffffff2, 0xe000000012dffe70)
        kernel .text 0xe000000004400000 0xe000000004425720
0xe000000004425b00
0xe000000004425e10 setup_frame+0x310
        args (0xb, 0xe00000001219b878, 0xfffffffffffffff2,
0xe000000012df8f00, 0xe000000012dffe60)
        kernel .text 0xe000000004400000 0xe000000004425b00
0xe000000004425f40
0xe000000004426170 handle_signal+0x230
        args (0xb, 0xe00000001219b878, 0xe000000012dffde0,
0xe000000012df8f00, 0xe000000012dffe60)
        kernel .text 0xe000000004400000 0xe000000004425f40
0xe000000004426180
0xe000000004426560 ia64_do_signal+0x3e0
        args (0xe000000012df8f00, 0xe000000012dffe60, 0x0, 0xb,
0xe00000001219b878)
        kernel .text 0xe000000004400000 0xe000000004426180
0xe000000004426a40
0xe00000000440a350 handle_signal_delivery+0x30
        args (0x80000000f, 0xa0200000000, 0xe000000012dffde4, 0x800000004,
0xe000000012dffdfc)
        kernel .text 0xe000000004400000 0xe00000000440a320
0xe00000000440a380
0xe000000004409f90 ia64_leave_kernel+0x70
        args (0x80000000f, 0xa0200000000, 0xe000000012dffde4)
        kernel .text 0xe000000004400000 0xe000000004409f20
0xe00000000440a1b0

Problem 2(recursive call to __copy_user)
---------
[0]kdb> bt
0xe00000000489d840 __copy_user+0x800
        args (0xffffffff, 0xe0000000143f7c10, 0x14, 0xe0000000045dfec0)
        kernel .text 0xe000000004400000 0xe00000000489d040
0xe00000000489d940
0xe0000000045e06e0 semctl_main+0x9c0
        args (0xe00000001bdf6ad8, 0xfffffffbfff, 0xe000000004c839a0,
0xe000000004c83970, 0xffffffff)
        kernel .text 0xe000000004400000 0xe0000000045dfd20
0xe0000000045e0780
0xe0000000045e0f00 sys_semctl+0x1c0
        args (0x8001, 0x0, 0xd, 0xffffffff, 0x80100)
				XXXXXXXXXXX 
        kernel .text 0xe000000004400000 0xe0000000045e0d40
0xe0000000045e0f20
0xe000000004409f00 ia64_ret_from_syscall
        args (0x8001, 0x0, 0xd, 0xffffffff)
        kernel .text 0xe000000004400000 0xe000000004409f00
0xe000000004409f20
[0]kdb> go
...

[0]kdb> bt
0xe00000000489d840 __copy_user+0x800
        args (0xffffffff, 0xe0000000143f7c10, 0x1)
        kernel .text 0xe000000004400000 0xe00000000489d040
0xe00000000489d940
0xe00000000489d900 __copy_user+0x8c0
        args (0x100000000, 0x0, 0x1, 0x0, 0xe00000000489d900)
        kernel .text 0xe000000004400000 0xe00000000489d040
0xe00000000489d940
0xe00000000489d900 __copy_user+0x8c0
        args (0x100000000, 0x0, 0x14, 0x13, 0xe0000000045e06e0)
        kernel .text 0xe000000004400000 0xe00000000489d040
0xe00000000489d940
0xe00000000489d900 __copy_user+0x8c0
        args (0xa, 0xa, 0xe0000000143f7c10, 0xe0000000045e0f00, 0x794)
        kernel .text 0xe000000004400000 0xe00000000489d040
0xe00000000489d940
0xe00000000489d900 __copy_user+0x8c0
        args (0xfffffffbfff, 0xe000000004c839a0, 0xe000000004c83970,
0xffffffff, 0x0)
        kernel .text 0xe000000004400000 0xe00000000489d040
0xe00000000489d940
0xe00000000489d900 __copy_user+0x8c0
        args (0x0, 0xffffffff, 0x1, 0xe000000004409f00, 0x4)
        kernel .text 0xe000000004400000 0xe00000000489d040
0xe00000000489d940
0xe00000000489d900 __copy_user+0x8c0
        args (0x80100, 0xe0000000143f7cd0, 0xe000000004409f20, 0x2, 0x8001)
        kernel .text 0xe000000004400000 0xe00000000489d040
0xe00000000489d940
0xe00000000489d900 __copy_user+0x8c0
[0]more> 
        args (0xc00000000000050d, 0x60000fffffffb9c0, 0x8001, 0x0, 0xd)
        kernel .text 0xe000000004400000 0xe00000000489d040
0xe00000000489d940
[0]kdb> 

Thanks for your help...
Xavier

David Mosberger writes:
 > >>>>> On Wed, 26 Jun 2002 19:30:48 +0200 (DFT), Xavier Bru
<Xavier.Bru@bull.net> said:
 > 
 >   Xavier> It seems that null pointers passed as argument to syscalls
 >   Xavier> by wrong user code now generate a Oops, and enter kdb if
 >   Xavier> enabled.
 > 
 > I haven't seen a fix from Ken yet, so the patch below comes live from
OLS...
 > Please test heavily and let me know how it goes.
 > 
 > Thanks,
 > 
 > 	--david
 > 
 > --- lia64-2.4/arch/ia64/kernel/traps.c~	Thu Jun 20 18:56:08 2002
 > +++ lia64-2.4/arch/ia64/kernel/traps.c	Fri Jun 28 12:15:58 2002
 > @@ -497,7 +497,8 @@
 >  			siginfo.si_isr = isr;
 >  			force_sig_info(sig, &siginfo, current);
 >  			return;
 > -		}
 > +		} else if (done_with_exception(regs))
 > +			return;
 >  		sprintf(buf, "NaT consumption");
 >  		break;
 >  

