From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Nov 2005 21:49:26 +0000
Subject: Re: [Patch 1/1] 4-level page tables v4.
Message-Id: <20051110214926.GA27555@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
In-Reply-To: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Compiling with three levels, I see some differences in the scheduling
of instructions in the vhpt_miss handler and the nested_dtlb miss
handler.  Side-by-side diff of a disassembly included below (original
sequence is on the left, new sequence is on the right).  For the vhpt
case the new handler is 3 instructions shorter ... but shorter isn't
always better.

Ken, David ... can you cast an eye across these please.

-Tony

P.S. there are no other instruction differences in the remainder of
the kernel ... a good indication that you managed to dot all the Is
and cross all the Ts when changing the macros in the header files.

a000000100000000 <vhpt_miss>:					a000000100000000 <vhpt_miss>:
a000000100000000:	[MLX]       mov r16=cr20		a000000100000000:	[MLX]       mov r16=cr20
a000000100000006:	            movl r18=0xe		a000000100000006:	            movl r18=0xe
a000000100000010:	[MMI]       mov r25=cr21;;		a000000100000010:	[MMI]       mov r25=cr21;;
a000000100000016:	            rsm 0x20000			a000000100000016:	            rsm 0x20000
a00000010000001c:	            mov r31=pr			a00000010000001c:	            mov r31=pr
a000000100000020:	[MII]       mov.m r19=ar.k7		a000000100000020:	[MII]       mov.m r19=ar.k7
a000000100000026:	            shl r21=r16,3		a000000100000026:	            shl r21=r16,3
a00000010000002c:	            shr.u r17=r16,61;;		a00000010000002c:	            shr.u r17=r16,61;;
a000000100000030:	[MII]       nop.m 0x0			a000000100000030:	[MII]       nop.m 0x0
a000000100000036:	            shr r22=r21,3	      |	a000000100000036:	            shr.u r22=r21,3
a00000010000003c:	            extr.u r26=r25,2,6;;	a00000010000003c:	            extr.u r26=r25,2,6;;
a000000100000040:	[MII]       cmp.eq p0,p8=r18,r26	a000000100000040:	[MII]       cmp.eq p0,p8=r18,r26
a000000100000046:	            sub r27=r26,r18;;		a000000100000046:	            sub r27=r26,r18;;
a00000010000004c:	      (p08) dep r25=r18,r25,2,6		a00000010000004c:	      (p08) dep r25=r18,r25,2,6
a000000100000050:	[MII]       nop.m 0x0			a000000100000050:	[MII]       nop.m 0x0
a000000100000056:	      (p08) shr r22=r22,r27;;		a000000100000056:	      (p08) shr r22=r22,r27;;
a00000010000005c:	            cmp.eq p6,p7=5,r17		a00000010000005c:	            cmp.eq p6,p7=5,r17
a000000100000060:	[MII]       nop.m 0x0			a000000100000060:	[MII]       nop.m 0x0
a000000100000066:	            shr.u r18=r22,36;;		a000000100000066:	            shr.u r18=r22,36;;
a00000010000006c:	      (p07) dep r17=r17,r19,11,3	a00000010000006c:	      (p07) dep r17=r17,r19,11,3
a000000100000070:	[MLX]       srlz.d			a000000100000070:	[MLX]       srlz.d
a000000100000076:	      (p06) movl r19=0xa0000001008980	a000000100000076:	      (p06) movl r19=0xa0000001008980
a000000100000080:	[MII]       nop.m 0x0			a000000100000080:	[MII]       nop.m 0x0
a000000100000086:	      (p06) shr.u r21=r21,50		a000000100000086:	      (p06) shr.u r21=r21,50
a00000010000008c:	      (p07) shr.u r21=r21,47;;		a00000010000008c:	      (p07) shr.u r21=r21,47;;
a000000100000090:	[MII]       nop.m 0x0			a000000100000090:	[MII]       nop.m 0x0
a000000100000096:	      (p06) dep r17=r18,r19,3,11	a000000100000096:	      (p06) dep r17=r18,r19,3,11
a00000010000009c:	      (p07) dep r17=r18,r17,3,8		a00000010000009c:	      (p07) dep r17=r18,r17,3,8
a0000001000000a0:	[MFI]       cmp.eq p7,p6=0,r21		a0000001000000a0:	[MFI]       cmp.eq p7,p6=0,r21
a0000001000000a6:	            nop.f 0x0			a0000001000000a6:	            nop.f 0x0
a0000001000000ac:	            shr.u r18=r22,25;;	      |	a0000001000000ac:	            shr.u r20=r22,25;;
a0000001000000b0:	[MMI]       ld8 r17=[r17];;		a0000001000000b0:	[MMI]       ld8 r17=[r17];;
a0000001000000b6:	      (p07) cmp.eq p6,p7=r17,r0	      |	a0000001000000b6:	            nop.m 0x0
a0000001000000bc:	            dep r17=r18,r17,3,11;;    |	a0000001000000bc:	            dep r30=r20,r17,3,11
a0000001000000c0:	[MII] (p07) ld8 r20=[r17]	      |	a0000001000000c0:	[MMI] (p07) cmp.eq p6,p7=r17,r0;;
a0000001000000c6:	            shr.u r19=r22,14;;	      |	a0000001000000c6:	      (p07) ld8 r20=[r30]
a0000001000000cc:	      (p07) cmp.eq.or.andcm p6,p7=r20 |	a0000001000000cc:	            shr.u r19=r22,14;;
a0000001000000d0:	[MFI]       nop.m 0x0		      |	a0000001000000d0:	[MII]       nop.m 0x0
a0000001000000d6:	            nop.f 0x0		      |	a0000001000000d6:	            dep r21=r19,r20,3,11
a0000001000000dc:	            dep r21=r19,r20,3,11;;    |	a0000001000000dc:	      (p07) cmp.eq.or.andcm p6,p7=r20
a0000001000000e0:	[MMI] (p07) ld8 r18=[r21]	      |	a0000001000000e0:	[MFI] (p07) ld8 r18=[r21]
a0000001000000e6:	            mov r19=cr17	      |	a0000001000000e6:	            nop.f 0x0
a0000001000000ec:	            nop.i 0x0;;		      |	a0000001000000ec:	            dep r23=0,r20,0,14
a0000001000000f0:	[MFI]       nop.m 0x0		      |	a0000001000000f0:	[MMI]       mov r19=cr17;;
a0000001000000f6:	            nop.f 0x0		      |	a0000001000000f6:	            nop.m 0x0
a0000001000000fc:	      (p07) tbit.z p6,p7=r18,0		a0000001000000fc:	      (p07) tbit.z p6,p7=r18,0
a000000100000100:	[MMI]       mov r22=cr25;;		a000000100000100:	[MMI]       mov r22=cr25;;
a000000100000106:	            nop.m 0x0			a000000100000106:	            nop.m 0x0
a00000010000010c:	      (p07) tbit.z.unc p11,p10=r19,32 |	a00000010000010c:	      (p07) tbit.z.unc p11,p10=r19,32
a000000100000110:	[MFI]       nop.m 0x0		      |	a000000100000110:	[MMI] (p10) itc.i r18;;
a000000100000116:	            nop.f 0x0		      |	a000000100000116:	            nop.m 0x0
a00000010000011c:	            dep r23=0,r20,0,14;;      |	a00000010000011c:	            nop.i 0x0;;
a000000100000120:	[MMI] (p10) itc.i r18;;		      |	a000000100000120:	[MMI] (p11) itc.d r18;;
a000000100000126:	            nop.m 0x0			a000000100000126:	            nop.m 0x0
a00000010000012c:	            nop.i 0x0;;		      |	a00000010000012c:	            nop.i 0x0
a000000100000130:	[MMI] (p11) itc.d r18;;		      |	a000000100000130:	[MFB]       nop.m 0x0
a000000100000136:	            nop.m 0x0		      |	a000000100000136:	            nop.f 0x0
a00000010000013c:	            nop.i 0x0		      |	a00000010000013c:	      (p06) br.cond.spnt.many a000000
a000000100000140:	[MFB]       nop.m 0x0		      |	a000000100000140:	[MMI]       mov cr20=r22
a000000100000146:	            nop.f 0x0		      |	a000000100000146:	      (p08) mov cr21=r25
a00000010000014c:	      (p06) br.cond.spnt.many a000000 |	a00000010000014c:	            adds r2421,r23;;
a000000100000150:	[MMI]       mov cr20=r22	      |	a000000100000150:	[MMI] (p07) itc.d r24;;
a000000100000156:	      (p08) mov cr21=r25	      |	a000000100000156:	            ld8 r26=[r30]
a00000010000015c:	            adds r2421,r23;;	      |	a00000010000015c:	            nop.i 0x0;;
a000000100000160:	[MMI] (p07) itc.d r24;;		      |	a000000100000160:	[MFI]       cmp.eq p7,p6=r26,r20
a000000100000166:	            ld8 r25=[r21]	      |	a000000100000166:	            nop.f 0x0
a00000010000016c:	            nop.i 0x0		      |	a00000010000016c:	            mov r27V
a000000100000170:	[MMI]       ld8 r26=[r17];;	      |	a000000100000170:	[MMI]       ld8 r25=[r21];;
a000000100000176:	            cmp.eq p7,p6=r26,r20      |	a000000100000176:	      (p06) ptc.l r22,r27
a00000010000017c:	            mov r27V;;	      |	a00000010000017c:	      (p07) cmp.ne.or.andcm p6,p7=r25
a000000100000180:	[MFI] (p06) ptc.l r22,r27	      |	a000000100000180:	[MIB] (p06) ptc.l r16,r27
a000000100000186:	            nop.f 0x0		      |	a000000100000186:	            mov pr=r31,0xffffffffffff
a00000010000018c:	      (p07) cmp.ne.or.andcm p6,p7=r25 |	a00000010000018c:	            rfi;;
a000000100000190:	[MIB] (p06) ptc.l r16,r27	      <
a000000100000196:	            mov pr=r31,0xffffffffffff <
a00000010000019c:	            rfi;;		      <

a000000100001400 <nested_dtlb_miss>:				a000000100001400 <nested_dtlb_miss>:
a000000100001400:	[MMI]       rsm 0x20000			a000000100001400:	[MMI]       rsm 0x20000
a000000100001406:	            mov.m r19=ar.k7		a000000100001406:	            mov.m r19=ar.k7
a00000010000140c:	            shl r21=r16,3		a00000010000140c:	            shl r21=r16,3
a000000100001410:	[MMI]       mov r18=cr21;;		a000000100001410:	[MMI]       mov r18=cr21;;
a000000100001416:	            nop.m 0x0			a000000100001416:	            nop.m 0x0
a00000010000141c:	            shr.u r17=r16,61		a00000010000141c:	            shr.u r17=r16,61
a000000100001420:	[MII]       nop.m 0x0			a000000100001420:	[MII]       nop.m 0x0
a000000100001426:	            extr.u r18=r18,2,6;;	a000000100001426:	            extr.u r18=r18,2,6;;
a00000010000142c:	            cmp.eq p6,p7=5,r17		a00000010000142c:	            cmp.eq p6,p7=5,r17
a000000100001430:	[MII]       adds r22=-14,r18		a000000100001430:	[MII]       adds r22=-14,r18
a000000100001436:	            adds r18",r18;;		a000000100001436:	            adds r18",r18;;
a00000010000143c:	            shr.u r22=r16,r22		a00000010000143c:	            shr.u r22=r16,r22
a000000100001440:	[MII]       nop.m 0x0			a000000100001440:	[MII]       nop.m 0x0
a000000100001446:	            shr.u r18=r16,r18		a000000100001446:	            shr.u r18=r16,r18
a00000010000144c:	      (p07) dep r17=r17,r19,11,3	a00000010000144c:	      (p07) dep r17=r17,r19,11,3
a000000100001450:	[MLX]       srlz.d			a000000100001450:	[MLX]       srlz.d
a000000100001456:	      (p06) movl r19=0xa0000001008980	a000000100001456:	      (p06) movl r19=0xa0000001008980
a000000100001460:	[MII]       nop.m 0x0			a000000100001460:	[MII]       nop.m 0x0
a000000100001466:	      (p06) shr.u r21=r21,50		a000000100001466:	      (p06) shr.u r21=r21,50
a00000010000146c:	      (p07) shr.u r21=r21,47;;		a00000010000146c:	      (p07) shr.u r21=r21,47;;
a000000100001470:	[MII]       nop.m 0x0			a000000100001470:	[MII]       nop.m 0x0
a000000100001476:	      (p06) dep r17=r18,r19,3,11	a000000100001476:	      (p06) dep r17=r18,r19,3,11
a00000010000147c:	      (p07) dep r17=r18,r17,3,8		a00000010000147c:	      (p07) dep r17=r18,r17,3,8
a000000100001480:	[MFI]       cmp.eq p7,p6=0,r21	      |	a000000100001480:	[MII]       cmp.eq p7,p6=0,r21
a000000100001486:	            nop.f 0x0		      |	a000000100001486:	            shr.u r18=r22,25;;
a00000010000148c:	            shr.u r18=r22,25;;	      |	a00000010000148c:	            shr.u r19=r22,14
a000000100001490:	[MMI]       ld8 r17=[r17];;		a000000100001490:	[MMI]       ld8 r17=[r17];;
a000000100001496:	      (p07) cmp.eq p6,p7=r17,r0		a000000100001496:	      (p07) cmp.eq p6,p7=r17,r0
a00000010000149c:	            dep r17=r18,r17,3,11;;	a00000010000149c:	            dep r17=r18,r17,3,11;;
a0000001000014a0:	[MII] (p07) ld8 r17=[r17]	      |	a0000001000014a0:	[MMI] (p07) ld8 r17=[r17];;
a0000001000014a6:	            shr.u r19=r22,14;;	      |	a0000001000014a6:	      (p07) cmp.eq.or.andcm p6,p7=r17
a0000001000014ac:	      (p07) cmp.eq.or.andcm p6,p7=r17 |	a0000001000014ac:	            dep r17=r19,r17,3,11
a0000001000014b0:	[MIB]       nop.m 0x0		      |	a0000001000014b0:	[MFB]       nop.m 0x0
a0000001000014b6:	            dep r17=r19,r17,3,11      |	a0000001000014b6:	            nop.f 0x0
a0000001000014bc:	      (p06) br.cond.spnt.few a0000001	a0000001000014bc:	      (p06) br.cond.spnt.few a0000001
a0000001000014c0:	[MIB]       nop.m 0x0			a0000001000014c0:	[MIB]       nop.m 0x0
a0000001000014c6:	            mov b0=r30			a0000001000014c6:	            mov b0=r30
a0000001000014cc:	            br.many b0;;		a0000001000014cc:	            br.many b0;;
