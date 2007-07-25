From: Doug Chapman <doug.chapman@hp.com>
Date: Wed, 25 Jul 2007 01:12:09 +0000
Subject: Re: panic from vector domain patch (was RE: Linus' tree broken?)
Message-Id: <1185325929.14444.6.camel@phobos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185239265.19353.6.camel@phobos>
In-Reply-To: <1185239265.19353.6.camel@phobos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2007-07-25 at 09:19 +0900, Yasuaki Ishimatsu wrote:
> Hi Doug,
> > 
> > Yasuaki,
> > 
> > With this patch it still panics in the same way.  I am building with
> > CONFIG_IA64_GENERIC and booting on an HP rx6600.  I do not have the ski
> > simulator either.
> > 
> 
> I don't know what happen on your machine. Could you send me your entire
> stack trace?
> 
> Thanks,
> Yasuaki Ishimatsu

Here is the panic with a few lines from before to show some context as
to when it happens (fairly early in boot).  I have to admit I have no
clue as to why your patch causes this.  I don't see anything that
appears to be related.  I will see if I can get a little more data.  If
you have suggestions for what might be helpful please let me know.


SAL Platform features: None
SAL: AP wakeup using external interrupt vector 0xff
cpu package is Multi-Core capable: number of cores=2
cpu package is Multi-Threading capable: number of siblings=2
ACPI: Local APIC address c0000000fee00000
GSI 25 (level, low) -> CPU 0 (0x0000) vector 48
16 CPUs available, 16 CPUs total
MCA related initialization done
kernel unaligned access to 0xffffffffffffffff, ip=0xa000000100815491
swapper[0]: error during unaligned kernel access
 -1 [1]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 00001210084a2010 ifs : 800000000000030a ip  : [<a000000100815491>]    Not tainted
ip is at setup_arch+0x671/0x720
unat: 0000000000000000 pfs : 000000000000030a rsc : 0000000000000003
rnat: 89543ffffe403fc4 bsps: 0000000000010017 pr  : 656960155aa66599
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100815470 b6  : a000000100304a80 b7  : a0000001000132e0
f6  : 1003e0000000000000000 f7  : 1003e0000000000000000
f8  : 1003e0000000000000000 f9  : 1003e0000000000000001
f10 : 10004c7ffffffff380000 f11 : 1003e0000000000000032
r1  : a000000100d2f000 r2  : a000000100b49248 r3  : a000000100a4f220
r8  : 0000000000000023 r9  : 0000000000004000 r10 : a000000100b536a8
r11 : a000000100b3a8a0 r12 : a0000001008b7d60 r13 : a0000001008b0000
r14 : 0000000000000000 r15 : a000000100a4f220 r16 : ffffffffdead4ead
r17 : 00000000dead4ead r18 : a0000001009e13fc r19 : a000000100b3a870
r20 : 000000000001ffff r21 : a000000100b47840 r22 : 0000000000000000
r23 : a000000100b49218 r24 : a000000100b34058 r25 : 000000000001ffff
r26 : 0000000000020000 r27 : a000000100b47828 r28 : a000000100b47820
r29 : a0000001009e1400 r30 : 0000000000000000 r31 : a0000001009e1408



Here is the bit of code showing where the ip points to:

(gdb) list *setup_arch+0x671
0xa000000100815491 is in setup_arch (arch/ia64/kernel/setup.c:570).
565
566             /* enable IA-64 Machine Check Abort Handling unless disabled */
567             if (!nomca)
568                     ia64_mca_init();
569
570             platform_setup(cmdline_p);
571             paging_init();
572     }
573
574     /*




