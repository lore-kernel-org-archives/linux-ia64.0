From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 03 Feb 2003 22:33:31 +0000
Subject: [Linux-ia64] Preempt problems
Message-Id: <marc-linux-ia64-105590709805804@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805801@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805801@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peter@chubb.wattle.id.au> writes:
Peter> * -- weird kernel page faults
Peter> apparently during ia64_leave_kernel() (from the stack
Peter> backtrace), but with an IP address in region 0, after some
Peter> variable amount of uptime, apparently independent of anything
Peter> happening on the machine (at least, I haven't yet been able to
Peter> isolate anything that causes it).


I just got one of these on a straight 2.5.59+davidm's patches, on a
vanilla zx2000.  The kernel address is always the same, at 0xffe6bf10,
regardless of the kernel, and regardless of the command that was
(apparently) running at the time.


I've appended the Oops message.  On a previous (different kernel) I
printed out the iipa:   e00000003ff04420cc1
It also appears bogus.  Note that interrupts are off in the psr.


I'm at a loss as to how to debug this thing now.  Can anyone suggest
anything?  It *could* be a hardware problem (I've had problems with
this machine before).



Unable to handle kernel paging request at virtual address 00000000ffe6bf10
automount[288]: Oops 4294967296

Pid: 288, CPU 0, comm:            automount
psr : 0000101008022018 ifs : 800000000000048d ip  : [<00000000ffe6bf10>]    Not tainted
ip is at 0xffe6bf10
unat: 0000000000000000 pfs : 0000000000000d22 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 769dbd656f5a5865
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
b0  : e00000003ff04430 b6  : e00000003fef6a80 b7  : e00000003fef37b0
f6  : 1003e0000000000003fff f7  : 1003ecccccccccccccccd
f8  : 1000cfffc000000000000 f9  : 1003e0000000000000008
r1  : e00000003fe40000 r2  : e00000003ff04430 r3  : 0000000000000000
r8  : 00000000ffe6bf10 r9  : 0000000000000000 r10 : 0000000000000000
r11 : 0000000000000000 r12 : e0000040428d7380 r13 : e0000040428d0000
r14 : c0000000ff4661f8 r15 : c0000000ff44a040 r16 : 000000000074a040
r17 : 0000000000000001 r18 : 00000000000000ff r19 : 0000000000000200
r20 : 00000000000002ff r21 : a0000000000100c8 r22 : e00000003fef37b0
r23 : e000000004ab8318 r24 : e0000000049eec10 r25 : e000000004aa4228
r26 : 0000000000000006 r27 : e000000004ab93e8 r28 : 0000000000000019
r29 : 0000000000000000 r30 : 0000000000000000 r31 : 0000000000000000

Call Trace:
 [<e000000004416560>] show_stack+0x80/0xa0 sp=0xe0000040428d6f90 bsp=0xe0000040428d1b58
 [<e00000000442cef0>] die+0x110/0x1a0 sp=0xe0000040428d7150 bsp=0xe0000040428d1b30
 [<e000000004448450>] ia64_do_page_fault+0x310/0x840 sp=0xe0000040428d7150 bsp=0xe0000040428d1ad0
 [<e000000004411520>] ia64_leave_kernel+0x0/0x240 sp=0xe0000040428d71e0 bsp=0xe0000040428d1ad0
 <0>Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing

