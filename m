From: Keith Owens <kaos@sgi.com>
Date: Tue, 17 Dec 2002 03:20:28 +0000
Subject: Re: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805591@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 16 Dec 2002 18:51:53 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Tue, 17 Dec 2002 13:34:03 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> I built binutils-2.13.90.0.2-2 (from rh 8.0) on ia64.  I
>  Keith> extracted the generated assembler for ia64_fault as traps.S.
>  Keith> The bug still exists in 2.13.90.0.2.  traps.S has been sent
>  Keith> to Jim Wilson as a test case.
>
>Which compiler did you use?

I used gcc 2.96 20000731 (Red Hat Linux 7.1 2.96-101) to convert
traps.c to traps.S, then extracted the headers and ia64_fault for
testing against gas.  traps.S only has one body.  I wanted to avoid
dumping 530+ lines to the list but ...

Interesting that a different gcc which generates two bodies gets valid
unwind data, but this code with only one body generates invalid unwind
data.  David, what does your unwind data look like after assembling
this code?

	.file	"traps.c"
	.pred.safe_across_calls p1-p5,p16-p63
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
	;;
	cmp.ne p6, p7 = r15, r14
	adds r14 = 272, r12
	;;
	(p7) movl r15 = 8796093022208
	mov r36 = r14
	(p7) ld8 r14 = [r14]
	;;
	(p7) or r14 = r15, r14
	(p7) mov r15 = r36
	;;
	(p7) st8 [r15] = r14
	(p7) br.cond.dpnt .L2880
	adds r15 = -24, r32
	;;
	cmp.ltu p6, p7 = 23, r15
	(p6) br.cond.dptk .L2936
	addl r14 = @ltoff(.L2937), gp
	;;
	ld8 r14 = [r14]
	;;
	shladd r16 = r15, 3, r14
	;;
	ld8 r15 = [r16]
	;;
	add r15 = r15, r14
	;;
	mov b6 = r15
	br b6
	.align 8
.L2937:
	data8 .L2883-.L2937
	data8 .L2889-.L2937
	data8 .L2903-.L2937
	data8 .L2936-.L2937
	data8 .L2936-.L2937
	data8 .L2915-.L2937
	data8 .L2936-.L2937
	data8 .L2911-.L2937
	data8 .L2926-.L2937
	data8 .L2926-.L2937
	data8 .L2929-.L2937
	data8 .L2915-.L2937
	data8 .L2915-.L2937
	data8 .L2936-.L2937
	data8 .L2936-.L2937
	data8 .L2936-.L2937
	data8 .L2936-.L2937
	data8 .L2936-.L2937
	data8 .L2936-.L2937
	data8 .L2936-.L2937
	data8 .L2936-.L2937
	data8 .L2931-.L2937
	data8 .L2933-.L2937
	data8 .L2935-.L2937
	.align 16
.L2883:
	extr.u r35 = r33, 4, 4
	addl r14 = @ltoff(reason.3#), gp
	adds r34 = 144, r12
	;;
	cmp.ne p6, p7 = 3, r35
	ld8 r14 = [r14]
	mov r39 = r34
	;;
	shladd r14 = r35, 3, r14
	(p6) addl r42 = @ltoff(.LC31), gp
	;;
	ld8 r41 = [r14]
	(p6) ld8 r42 = [r42]
	(p6) br.cond.dptk .L2885
	tbit.z p6, p7 = r33, 37
	;;
	(p7) addl r42 = @ltoff(.LC29), gp
	;;
	(p7) ld8 r42 = [r42]
	(p6) addl r42 = @ltoff(.LC30), gp
	;;
	(p6) ld8 r42 = [r42]
.L2885:
	addl r40 = @ltoff(.LC28), gp
	;;
	ld8 r40 = [r40]
	br.call.sptk.many b0 = sprintf#
	;;
	cmp.ne p6, p7 = 8, r35
	(p6) br.cond.dptk .L2882
	adds r15 = 64, r36
	adds r14 = 8, r36
	addl r39 = @ltoff(.LC32), gp
	;;
	ld8 r40 = [r14]
	ld8 r41 = [r15]
	ld8 r39 = [r39]
	br.call.sptk.many b0 = printk#
	;;
	br .L2880
.L2889:
	tbit.z p6, p7 = r33, 1
	(p6) br.cond.dpnt .L2890
	ld8 r14 = [r36]
	addl r15 = -524289, r0
	;;
	and r14 = r15, r14
	;;
	st8 [r36] = r14
#APP
	mov ar.k5=r13
#NO_APP
	adds r14 = 1496, r13
	;;
	ld4 r15 = [r14]
	;;
	tbit.z p6, p7 = r15, 0
	(p6) br.cond.dpnt .L2901
	adds r39 = 2272, r13
	br.call.sptk.many b0 = __ia64_load_fpu#
	;;
	ld8 r14 = [r36]
	;;
	and r14 = -33, r14
	;;
	st8 [r36] = r14
	br .L2880
.L2901:
	br.call.sptk.many b0 = __ia64_init_fpu#
	;;
	ld8 r14 = [r36]
	;;
	or r14 = 32, r14
	;;
	st8 [r36] = r14
	br .L2880
.L2890:
	adds r34 = 144, r12
	addl r40 = @ltoff(.LC33), gp
	br .L2938
.L2903:
	ld8 r17 = [r36]
	;;
	mov r15 = r17
	;;
	extr.u r14 = r15, 32, 2
	;;
	cmp4.eq p6, p7 = 0, r14
	(p6) br.cond.dpnt .L2904
	extr.u r14 = r33, 4, 4
	adds r17 = 8, r36
	extr.u r15 = r15, 41, 2
	;;
	cmp.ne p6, p7 = 2, r14
	adds r16 = 20, r12
	adds r18 = 44, r12
	;;
	(p7) addl r39 = 11, r0
	adds r14 = 16, r12
	(p7) addl r35 = 196610, r0
	(p6) addl r39 = 4, r0
	(p6) addl r35 = 196610, r0
	mov r41 = r13
	;;
	st4 [r14] = r39
	adds r14 = 24, r12
	;;
	st4 [r14] = r35
	ld8 r14 = [r17]
	st4 [r16] = r0
	;;
	add r14 = r14, r15
	adds r17 = 32, r12
	;;
	st8 [r17] = r14
	adds r15 = 40, r12
	addl r16 = 1, r0
	;;
	st4 [r15] = r32
	adds r14 = 48, r12
	adds r15 = 16, r12
	st4 [r18] = r16
	;;
	mov r40 = r15
	st8 [r14] = r33
	br.call.sptk.many b0 = force_sig_info#
	;;
	br .L2880
.L2904:
	adds r14 = 8, r36
	;;
	ld8 r39 = [r14]
	br.call.sptk.many b0 = search_exception_table#
	;;
	cmp.eq p6, p7 = 0, r8
	;;
	(p6) mov r14 = r0
	(p6) br.cond.dpnt .L2910
	mov r40 = r8
	mov r39 = r36
	br.call.sptk.many b0 = handle_exception#
	;;
	addl r14 = 1, r0
	;;
.L2910:
	cmp4.eq p6, p7 = 0, r14
	(p7) br.cond.dptk .L2880
	adds r34 = 144, r12
	addl r40 = @ltoff(.LC34), gp
	br .L2938
.L2911:
	ld8 r17 = [r36]
	;;
	extr.u r14 = r17, 32, 2
	;;
	cmp4.eq p6, p7 = 0, r14
	(p6) br.cond.dpnt .L2912
	adds r14 = 16, r12
	addl r39 = 4, r0
	adds r16 = 24, r12
	;;
	st4 [r14] = r39
	adds r18 = 8, r36
	extr.u r17 = r17, 41, 2
	addl r14 = 196610, r0
	mov r41 = r13
	;;
	st4 [r16] = r14
	ld8 r15 = [r18]
	adds r14 = 20, r12
	adds r16 = 40, r12
	;;
	st4 [r14] = r0
	add r15 = r15, r17
	adds r14 = 32, r12
	;;
	st8 [r14] = r15
	st4 [r16] = r32
	adds r15 = 44, r12
	addl r14 = 1, r0
	;;
	st4 [r15] = r14
	adds r16 = 48, r12
	adds r15 = 16, r12
	;;
	st8 [r16] = r33
	br .L2939
.L2912:
	adds r34 = 144, r12
	addl r40 = @ltoff(.LC35), gp
	br .L2938
.L2915:
	cmp.eq p6, p7 = 35, r32
	;;
	(p6) adds r15 = 24, r12
	(p6) addl r14 = 196611, r0
	(p6) mov r34 = r0
	;;
	(p6) st4 [r15] = r14
	(p6) ld8 r17 = [r36]
	(p6) br.cond.dpnt .L2916
	cmp.ltu p6, p7 = 35, r32
	(p6) br.cond.dptk .L2923
	;;
	cmp.eq p6, p7 = 29, r32
	(p6) br.cond.dpnt .L2917
	ld8 r17 = [r36]
	br .L2916
	;;
.L2923:
	cmp.eq p6, p7 = 36, r32
	;;
	(p6) adds r15 = 24, r12
	(p6) addl r14 = 196610, r0
	(p6) mov r34 = r0
	;;
	(p6) st4 [r15] = r14
	(p6) ld8 r17 = [r36]
	(p6) br.cond.dpnt .L2916
	;;
	ld8 r17 = [r36]
	br .L2916
.L2917:
	addl r14 = 196612, r0
	;;
	ld8 r17 = [r36]
	adds r15 = 24, r12
	;;
	st4 [r15] = r14
	tbit.nz p6, p7 = r17, 34
	;;
	(p7) adds r14 = 8, r36
	;;
	(p7) ld8 r34 = [r14]
.L2916:
	extr.u r14 = r17, 32, 2
	;;
	cmp4.ne p6, p7 = 0, r14
	(p6) br.cond.dptk .L2924
	mov r40 = r32
	mov r41 = r36
	addl r39 = 4, r0
	br.call.sptk.many b0 = kdb#
	;;
	cmp4.eq p6, p7 = 0, r8
	(p7) br.cond.dptk .L2880
.L2924:
	adds r16 = 16, r12
	addl r39 = 5, r0
	adds r15 = 44, r12
	;;
	mov r14 = r16
	adds r17 = 48, r12
	adds r18 = 32, r12
	;;
	st4 [r14] = r39, 4
	adds r16 = 40, r12
	mov r41 = r13
	;;
	st4 [r14] = r0
	st4 [r15] = r0
	adds r14 = 16, r12
	st8 [r17] = r0
	;;
	mov r40 = r14
	st8 [r18] = r34
	br .L2940
.L2926:
	cmp.eq p6, p7 = 32, r32
	;;
	mov r40 = r36
	mov r41 = r33
	(p6) addl r39 = 1, r0
	(p7) mov r39 = r0
	br.call.sptk.many b0 = handle_fpu_swa#
	;;
	cmp4.gt p6, p7 = r0, r8
	(p6) br.cond.dpnt .L2928
	adds r14 = 1496, r13
	;;
	ld8 r15 = [r14]
	;;
	tbit.nz p6, p7 = r15, 7
	(p7) br.cond.dpnt .L2880
.L2928:
	adds r15 = 16, r12
	addl r39 = 8, r0
	adds r17 = 8, r36
	;;
	mov r14 = r15
	adds r18 = 24, r12
	mov r41 = r13
	ld8 r15 = [r36]
	;;
	st4 [r14] = r39, 4
	extr.u r15 = r15, 41, 2
	;;
	st4 [r14] = r0
	ld8 r16 = [r17]
	addl r14 = 196615, r0
	;;
	st4 [r18] = r14
	add r16 = r16, r15
	adds r17 = 32, r12
	;;
	st8 [r17] = r16
	addl r14 = 1, r0
	adds r15 = 44, r12
	;;
	st4 [r15] = r14
	adds r18 = 48, r12
	adds r16 = 40, r12
	adds r14 = 16, r12
	;;
	st8 [r18] = r33
	mov r40 = r14
.L2940:
	st4 [r16] = r0
	br.call.sptk.many b0 = force_sig_info#
	;;
	br .L2880
.L2929:
	ld8 r20 = [r36]
	;;
	extr.u r14 = r20, 32, 2
	;;
	cmp4.eq p6, p7 = 0, r14
	(p6) br.cond.dpnt .L2930
	adds r15 = 16, r12
	addl r39 = 4, r0
	adds r16 = 24, r12
	;;
	st4 [r15] = r39
	addl r14 = 196617, r0
	adds r17 = 20, r12
	;;
	st4 [r16] = r14
	adds r15 = 8, r36
	adds r18 = 44, r12
	st4 [r17] = r0
	adds r19 = 48, r12
	extr.u r16 = r20, 41, 2
	;;
	ld8 r14 = [r15]
	mov r41 = r13
	st4 [r18] = r0
	adds r15 = 40, r12
	;;
	add r14 = r14, r16
	st8 [r19] = r0
	adds r16 = 32, r12
	st4 [r15] = r0
	adds r15 = 16, r12
	;;
	st8 [r16] = r14
.L2939:
	mov r40 = r15
	br.call.sptk.many b0 = force_sig_info#
	;;
	br .L2880
.L2930:
	adds r34 = 144, r12
	addl r40 = @ltoff(.LC36), gp
	;;
.L2938:
	mov r39 = r34
	ld8 r40 = [r40]
	br.call.sptk.many b0 = sprintf#
	;;
	br .L2882
.L2931:
	mov r39 = r36
	mov r40 = r33
	br.call.sptk.many b0 = ia32_exception#
	;;
	cmp4.ne p6, p7 = 0, r8
	(p7) br.cond.dpnt .L2880
	addl r39 = @ltoff(.LC37), gp
	;;
	ld8 r39 = [r39]
	br.call.sptk.many b0 = printk#
	;;
	addl r39 = @ltoff(.LC38), gp
	adds r14 = 8, r36
	mov r41 = r34
	;;
	ld8 r40 = [r14]
	ld8 r39 = [r39]
	mov r42 = r33
	br.call.sptk.many b0 = printk#
	;;
	addl r39 = 11, r0
	mov r40 = r13
	br.call.sptk.many b0 = force_sig#
	;;
	adds r34 = 144, r12
	br .L2882
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


