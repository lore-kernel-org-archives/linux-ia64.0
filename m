From: Keith Owens <kaos@sgi.com>
Date: Mon, 16 Dec 2002 22:12:25 +0000
Subject: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805576@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 16 Dec 2002 16:25:15 -0500, 
Jim Wilson <wilson@redhat.com> wrote:
>>RH 7.2-ia64, Dec 15 2001.
>
>The tools for this release were based on Summer 2000 FSF sources with patches.
>So they are about 2.5 years old now.

I know, but AFAICT it is the latest that is available on the RH site
for ia64.  If there is a more recent binutils ia64.rpm, point me at it
and I will try it.

>Are you sure this is an assembler problem?  If the compiler is emitting bad
>unwind directives, then it could be a compiler problem.  You didn't mention
>anything about looking at assembly code.

See my follow up mail about memset.S, that is pure assembler.  But just
to be sure, here is traps.c::ia64_fault assembler output.  No spurious
unwind directives from gcc but unwind is still wrong.

.text
	.align 16
	.align 32
	.global ia64_fault#
	.proc ia64_fault#
ia64_fault:
	.prologue 12, 37
	.save ar.pfs, r38
	alloc r38 = ar.pfs, 4, 3, 5, 0
	.fframe 256
	adds r12 = -256, r12
	movl r14 = 34359738383
	.save rp, r37
	mov r37 = b0
	;;
	.body
	and r14 = r14, r33
	movl r15 = 34359738372
[454 lines omitted for brevity]
.L2933:
	mov r39 = r36
	mov r40 = r33
	br.call.sptk.many b0 = ia32_intercept#
	;;
	cmp4.ne p6, p7 = 0, r8
	(p7) br.cond.dpnt .L2880
	addl r39 = @ltoff(.LC39), gp
	;;
	ld8 r39 = [r39]
	br.call.sptk.many b0 = printk#
	;;
	adds r14 = 8, r36
	addl r39 = @ltoff(.LC40), gp
	mov r41 = r34
	;;
	ld8 r40 = [r14]
	ld8 r39 = [r39]
	mov r42 = r33
	mov r43 = r35
	br.call.sptk.many b0 = printk#
[unwind tables in the object say that the body ends here]
	;;
	addl r39 = 11, r0
	mov r40 = r13
	br.call.sptk.many b0 = force_sig#
	;;
	br .L2880
.L2935:
	adds r34 = 144, r12
	addl r40 = @ltoff(.LC41), gp
	shr.u r41 = r33, 16
	;;
	mov r39 = r34
	ld8 r40 = [r40]
	br.call.sptk.many b0 = sprintf#
	;;
	br .L2882
.L2936:
	adds r34 = 144, r12
	addl r40 = @ltoff(.LC42), gp
	mov r41 = r32
	;;
	mov r39 = r34
	ld8 r40 = [r40]
	br.call.sptk.many b0 = sprintf#
	;;
.L2882:
	mov r39 = r34
	mov r40 = r36
	mov r41 = r33
	br.call.sptk.many b0 = die_if_kernel#
	;;
	addl r39 = 4, r0
	mov r40 = r13
	br.call.sptk.many b0 = force_sig#
	;;
.L2880:
	mov ar.pfs = r38
	mov b0 = r37
	.restore sp
	adds r12 = 256, r12
	br.ret.sptk.many b0
	.endp ia64_fault#



