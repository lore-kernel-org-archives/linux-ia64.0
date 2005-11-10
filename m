From: Robin Holt <holt@sgi.com>
Date: Thu, 10 Nov 2005 22:38:33 +0000
Subject: Re: [Patch 1/1] 4-level page tables v4.
Message-Id: <20051110223833.GA8037@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
In-Reply-To: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 10, 2005 at 01:49:26PM -0800, Luck, Tony wrote:
> Compiling with three levels, I see some differences in the scheduling
> of instructions in the vhpt_miss handler and the nested_dtlb miss
> handler.  Side-by-side diff of a disassembly included below (original
> sequence is on the left, new sequence is on the right).  For the vhpt
> case the new handler is 3 instructions shorter ... but shorter isn't
> always better.

I used the objdump that Jack Steiner pointed me towards to optomize the
vhpt_miss handler and then test.  This instruction order gave the best
performance, but we are talking extremely small differences.

Is the goal to make these identical?  If so, it should be easy to do,
but I was not aware that was the intent.

I am going to attach the dispersal analysis the modified objdump that
Jack has produced.

Thanks,
Robin

0000000000000000 <vhpt_miss>:						0000000000000000 <vhpt_miss>:
  0:    0         [MLX]       mov r16=cr20					  0:    0         [MLX]       mov r16=cr20
  6:    0                     movl r18=0xe					  6:    0                     movl r18=0xe
  c: 										  c:
 10:    1 R[M2]   [MMI]       mov r25=cr21;;					 10:    1 R[M2]   [MMI]       mov r25=cr21;;
 16:    2 S                   rsm 0x20000					 16:    2 S                   rsm 0x20000
 1c:    2                     mov r31=pr					 1c:    2                     mov r31=pr
 20:    3 R[M2]   [MII]       mov.m r19=ar.k7					 20:    3 R[M2]   [MII]       mov.m r19=ar.k7
 26:    3                     shl r21=r16,3					 26:    3                     shl r21=r16,3
 2c:    3                     shr.u r17=r16,61;;				 2c:    3                     shr.u r17=r16,61;;
 30:    4 S       [MII]       nop.m 0x0						 30:    4 S       [MII]       nop.m 0x0
 36:    4                     shr r22=r21,3				  |	 36:    4                     shr.u r22=r21,3
 3c:    5 R[I0]               extr.u r26=r25,2,6;;				 3c:    5 R[I0]               extr.u r26=r25,2,6;;
 40:    6 S       [MII]       cmp.eq p0,p8=r18,r26				 40:    6 S       [MII]       cmp.eq p0,p8=r18,r26
 46:    6                     sub r27=r26,r18;;					 46:    6                     sub r27=r26,r18;;
 4c:    7 S             (p08) dep r25=r18,r25,2,6				 4c:    7 S             (p08) dep r25=r18,r25,2,6
 50:    7         [MII]       nop.m 0x0						 50:    7         [MII]       nop.m 0x0
 56:    7               (p08) shr r22=r22,r27;;					 56:    7               (p08) shr r22=r22,r27;;
 5c:    8 S                   cmp.eq p6,p7=5,r17				 5c:    8 S                   cmp.eq p6,p7=5,r17
 60:    8         [MII]       nop.m 0x0						 60:    8         [MII]       nop.m 0x0
 66:    8                     shr.u r18=r22,36;;				 66:    8                     shr.u r18=r22,36;;
 6c:    9 S             (p07) dep r17=r17,r19,11,3				 6c:    9 S             (p07) dep r17=r17,r19,11,3
 70:    9         [MLX]       srlz.d						 70:    9         [MLX]       srlz.d
 76:    9               (p06) movl r19=0x0					 76:    9               (p06) movl r19=0x0
 7c: 										 7c:
 80:   10                     nop.m 0x0						 80:   10         [MII]       nop.m 0x0
 86:   10               (p06) shr.u r21=r21,50					 86:   10               (p06) shr.u r21=r21,50
 8c:   10               (p07) shr.u r21=r21,47;;				 8c:   10               (p07) shr.u r21=r21,47;;
 90:   11 S                   nop.m 0x0						 90:   11 S       [MII]       nop.m 0x0
 96:   11               (p06) dep r17=r18,r19,3,11				 96:   11               (p06) dep r17=r18,r19,3,11
 9c:   12 R[I0]         (p07) dep r17=r18,r17,3,8				 9c:   12 R[I0]         (p07) dep r17=r18,r17,3,8
 a0:   12                     cmp.eq p7,p6=0,r21				 a0:   12         [MFI]       cmp.eq p7,p6=0,r21
 a6:   12                     nop.f 0x0					  |	 a6:   12                     nop.f 0x0
 ac:   12                     shr.u r18=r22,25;;			  |	 ac:   12                     shr.u r20=r22,25;;
 b0:   13                     ld8 r17=[r17];;				  |	 b0:   13         [MMI]       ld8 r17=[r17];;
 b6:   14 S             (p07) cmp.eq p6,p7=r17,r0			  |	 b6:   14 S                   nop.m 0x0
 bc:   14                     dep r17=r18,r17,3,11;;			  |	 bc:   14                     dep r30=r20,r17,3,11
 c0:   15 S             (p07) ld8 r20=[r17]				  |	 c0:   14         [MMI] (p07) cmp.eq p6,p7=r17,r0;;
 c6:   15                     shr.u r19=r22,14;;			  |	 c6:   15 S             (p07) ld8 r20=[r30]
 cc:   16 S             (p07) cmp.eq.or.andcm p6,p7=r20,r0		  |	 cc:   15                     shr.u r19=r22,14;;
 d0:   16                     nop.m 0x0					  |	 d0:   16 S       [MII]       nop.m 0x0
 d6:   16                     nop.f 0x0					  |	 d6:   16                     dep r21=r19,r20,3,11
 dc:   17 R[I0]               dep r21=r19,r20,3,11;;			  |	 dc:   16               (p07) cmp.eq.or.andcm p6,p7=r20,r0;;
 e0:   18 S             (p07) ld8 r18=[r21]				  |	 e0:   17 S       [MFI] (p07) ld8 r18=[r21]
 e6:   18                     mov r19=cr17				  |	 e6:   17                     nop.f 0x0
 ec:   18                     nop.i 0x0;;				  |	 ec:   17                     dep r23=0,r20,0,14
 f0:   19 S                   nop.m 0x0					  |	 f0:   17         [MMI]       mov r19=cr17;;
 f6:   19                     nop.f 0x0					  |	 f6:   18 S                   nop.m 0x0
 fc:   19               (p07) tbit.z p6,p7=r18,0			  |	 fc:   18               (p07) tbit.z p6,p7=r18,0
100:   19                     mov r22=cr25;;				  |	100:   18         [MMI]       mov r22=cr25;;
106:   20 S                   nop.m 0x0					  |	106:   19 S                   nop.m 0x0
10c:   20               (p07) tbit.z.unc p11,p10=r19,32			  |	10c:   19               (p07) tbit.z.unc p11,p10=r19,32;;
110:   20                     nop.m 0x0					  |	110:   20 S       [MMI] (p10) itc.i r18;;
116:   20                     nop.f 0x0					  |	116:   21 S                   nop.m 0x0
11c:   21 R[I0]               dep r23=0,r20,0,14;;			  |	11c:   21                     nop.i 0x0;;
120:   22 S             (p10) itc.i r18;;				  |	120:   22 S       [MMI] (p11) itc.d r18;;
126:   23 S                   nop.m 0x0						126:   23 S                   nop.m 0x0
12c:   23                     nop.i 0x0;;				  |	12c:   23                     nop.i 0x0
130:   24 S             (p11) itc.d r18;;				  |	130:   23         [MFB]       nop.m 0x0
136:   25 S                   nop.m 0x0					  |	136:   23                     nop.f 0x0
13c:   25                     nop.i 0x0					  |	13c:   23               (p06) br.cond.spnt.many 1820 <page_fault>
140:   25                     nop.m 0x0					  |	140:   24         [MMI]       mov cr20=r22
146:   25                     nop.f 0x0					  |	146:   25 R[M2]         (p08) mov cr21=r25
14c:   25               (p06) br.cond.spnt.many 1820 <page_fault>	  |	14c:   25                     adds r2421,r23;;
150:   26                     mov cr20=r22				  |	150:   26 S       [MMI] (p07) itc.d r24;;
156:   27 R[M2]         (p08) mov cr21=r25				  |	156:   27 S                   ld8 r26=[r30]
15c:   27                     adds r2421,r23;;			  |	15c:   27                     nop.i 0x0;;
160:   28 S             (p07) itc.d r24;;				  |	160:   28 S       [MFI]       cmp.eq p7,p6=r26,r20
166:   29 S                   ld8 r25=[r21]				  |	166:   28                     nop.f 0x0
16c:   29                     nop.i 0x0					  |	16c:   28                     mov r27V
170:   29                     ld8 r26=[r17];;				  |	170:   28         [MMI]       ld8 r25=[r21];;
176:   30 S                   cmp.eq p7,p6=r26,r20			  |	176:   29 S             (p06) ptc.l r22,r27
17c:   30                     mov r27V;;				  |	17c:   29               (p07) cmp.ne.or.andcm p6,p7=r25,r18;;
180:   31 S             (p06) ptc.l r22,r27				  |	180:   30 S       [MIB] (p06) ptc.l r16,r27
186:   31                     nop.f 0x0					  |	186:   30                     mov pr=r31,0xfffffffffffffffe
18c:   31               (p07) cmp.ne.or.andcm p6,p7=r25,r18;;		  |	18c:   30                     rfi;;
190:   32 S             (p06) ptc.l r16,r27				  <
196:   32                     mov pr=r31,0xfffffffffffffffe		  <
19c:   32                     rfi;;					  <


...


0000000000001400 <nested_dtlb_miss>:						0000000000001400 <nested_dtlb_miss>:
1400: 	   0         [MMI]       rsm 0x20000					1400: 	   0         [MMI]       rsm 0x20000
1406: 	   1 R[M2]               mov.m r19=ar.k7				1406: 	   1 R[M2]               mov.m r19=ar.k7
140c: 	   1                     shl r21=r16,3					140c: 	   1                     shl r21=r16,3
1410: 	   2 R[M2]   [MMI]       mov r18=cr21;;					1410: 	   2 R[M2]   [MMI]       mov r18=cr21;;
1416: 	   3 S                   nop.m 0x0					1416: 	   3 S                   nop.m 0x0
141c: 	   3                     shr.u r17=r16,61				141c: 	   3                     shr.u r17=r16,61
1420: 	   3         [MII]       nop.m 0x0					1420: 	   3         [MII]       nop.m 0x0
1426: 	   4 R[I0]               extr.u r18=r18,2,6;;				1426: 	   4 R[I0]               extr.u r18=r18,2,6;;
142c: 	   5 S                   cmp.eq p6,p7=5,r17				142c: 	   5 S                   cmp.eq p6,p7=5,r17
1430: 	   5         [MII]       adds r22=-14,r18				1430: 	   5         [MII]       adds r22=-14,r18
1436: 	   5                     adds r18",r18;;				1436: 	   5                     adds r18",r18;;
143c: 	   6 S                   shr.u r22=r16,r22				143c: 	   6 S                   shr.u r22=r16,r22
1440: 	   6         [MII]       nop.m 0x0					1440: 	   6         [MII]       nop.m 0x0
1446: 	   6                     shr.u r18=r16,r18				1446: 	   6                     shr.u r18=r16,r18
144c: 	   7 R[I0]         (p07) dep r17=r17,r19,11,3				144c: 	   7 R[I0]         (p07) dep r17=r17,r19,11,3
1450: 	   7         [MLX]       srlz.d						1450: 	   7         [MLX]       srlz.d
1456: 	   7               (p06) movl r19=0x0					1456: 	   7               (p06) movl r19=0x0
145c: 										145c:
1460: 	   8         [MII]       nop.m 0x0					1460: 	   8         [MII]       nop.m 0x0
1466: 	   8               (p06) shr.u r21=r21,50				1466: 	   8               (p06) shr.u r21=r21,50
146c: 	   8               (p07) shr.u r21=r21,47;;				146c: 	   8               (p07) shr.u r21=r21,47;;
1470: 	   9 S       [MII]       nop.m 0x0					1470: 	   9 S       [MII]       nop.m 0x0
1476: 	   9               (p06) dep r17=r18,r19,3,11				1476: 	   9               (p06) dep r17=r18,r19,3,11
147c: 	  10 R[I0]         (p07) dep r17=r18,r17,3,8				147c: 	  10 R[I0]         (p07) dep r17=r18,r17,3,8
1480: 	  10         [MFI]       cmp.eq p7,p6=0,r21			  |	1480: 	  10         [MII]       cmp.eq p7,p6=0,r21
1486: 	  10                     nop.f 0x0				  |	1486: 	  10                     shr.u r18=r22,25;;
148c: 	  10                     shr.u r18=r22,25;;			  |	148c: 	  11 S                   shr.u r19=r22,14
1490: 	  11         [MMI]       ld8 r17=[r17];;				1490: 	  11         [MMI]       ld8 r17=[r17];;
1496: 	  12 S             (p07) cmp.eq p6,p7=r17,r0				1496: 	  12 S             (p07) cmp.eq p6,p7=r17,r0
149c: 	  12                     dep r17=r18,r17,3,11;;				149c: 	  12                     dep r17=r18,r17,3,11;;
14a0: 	  13 S       [MII] (p07) ld8 r17=[r17]				  |	14a0: 	  13 S       [MMI] (p07) ld8 r17=[r17];;
14a6: 	  13                     shr.u r19=r22,14;;			  |	14a6: 	  14 S             (p07) cmp.eq.or.andcm p6,p7=r17,r0
14ac: 	  14 S             (p07) cmp.eq.or.andcm p6,p7=r17,r0		  |	14ac: 	  14                     dep r17=r19,r17,3,11
14b0: 	  14         [MIB]       nop.m 0x0				  |	14b0: 	  14         [MFB]       nop.m 0x0
14b6: 	  15 R[I0]               dep r17=r19,r17,3,11			  |	14b6: 	  14                     nop.f 0x0
14bc: 	  15               (p06) br.cond.spnt.few 1820 <page_fault>	  |	14bc: 	  14               (p06) br.cond.spnt.few 1820 <page_fault>
14c0: 	  16 B       [MIB]       nop.m 0x0				  |	14c0: 	  15         [MIB]       nop.m 0x0
14c6: 	  16                     mov b0=r30				  |	14c6: 	  15                     mov b0=r30
14cc: 	  16                     br.many b0;;				  |	14cc: 	  15                     br.many b0;;
