From: Keith Owens <kaos@sgi.com>
Date: Fri, 20 Feb 2004 14:18:37 +0000
Subject: Re: Oops in pdflush
Message-Id: <5765.1077286717@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, 20 Feb 2004 14:34:03 +0100,=20
Andreas Schwab <schwab@suse.de> wrote:
>This happens regularily on all our Intel Tiger SMP systems, haven't seen
>it on UP systems, and neither on any HP system we have.  Theses oopses are
>all from different systems running kernels 2.6.2 and 2.6.3 in various
>incarnations.  They are all using e1000 and mptscsih, unlike the HP
>systems, so it might be a bug in either of those drivers.
>
>pdflush[5742]: Oops 11012296146944 [1]
>
>Pid: 5742, CPU 2, comm:              pdflush
>psr : 0000121008026018 ifs : 800000000000040b ip  : [<a000000100485d01>]  =
  Not tainted
>ip is at ip_finish_output2+0x41/0x560
>unat: 0000000000000000 pfs : 0000000000000797 rsc : 0000000000000003
>rnat: e000000007ac7890 bsps: 0000000000001310 pr  : 82aa6aa6a555969b
>ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
>csd : 0000000000000000 ssd : 0000000000000000
>b0  : a000000100451900 b6  : a000000100282bc0 b7  : a000000100485cc0
>f6  : 000000000000000000000 f7  : 1003e000000000011d541
>f8  : 1003e000000000016fa06 f9  : 1003e0000000000b38153
>f10 : 1003e000000000023aa82 f11 : 1003e0000000000000001
>r1  : a000000100988130 r2  : 000000005dde178a r3  : 0000000000100000
>r8  : 0000000000000001 r9  : 00000000000006a8 r10 : 840d3f83e0420336
>r11 : 840d3f83e04202b6 r12 : e000000007286830 r13 : e000000007280000
>r14 : 0000000000000001 r15 : a0000001004af498 r16 : a0000001004af530
>r17 : 000000005e01380a r18 : 0000000000232080 r19 : a0000001004af528
>r20 : a00000010084b2c0 r21 : 0000000000100000 r22 : 0000000000100000
>r23 : a0000001007e4ca0 r24 : a000000100485cc0 r25 : e000000007286840
>r26 : 00000000ffffffff r27 : e00000003feb66d8 r28 : 0000000000000000
>r29 : e00000003feb66d4 r30 : 0000000000100000 r31 : e00000003feb66d0
>
>Call Trace:
> [<a0000001000169e0>] show_stack+0x80/0xa0
>                                sp=E000000007286a38 bsp=E000000007286a18
> [<a000000100039270>] die+0x170/0x200
>                                sp=E000000007286c08 bsp=E0000000072869d8
> [<a000000100057760>] ia64_do_page_fault+0x720/0xa60
>                                sp=E000000007286c08 bsp=E000000007286970
> [<a00000010000d560>] ia64_leave_kernel+0x0/0x260
>                                sp=E000000007286c98 bsp=E000000007286970
> <0>Kernel panic: Aiee, killing interrupt handler!
>In interrupt handler - not syncing

You should be getting a better backtrace than that.  ia64_leave_kernel
is the start of the interrupt handler for the oops, the preceding trace
points are the interesting ones but they are missing.

Which compiler are you using?  It could be a compiler fault, not
generating correct unwind data.

Can you try running with the kdb patch to see if that gives a better
backtrace for the oops?

