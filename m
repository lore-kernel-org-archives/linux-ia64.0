From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 05 Mar 2004 00:16:25 +0000
Subject: cat /proc/acpi/events bad for your system's health!
Message-Id: <16455.50905.681007.50048@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Len,

While tracking down another ACPI problem, I thought I'd try this:

 # cat /proc/acpi/events

To my surprise pushing the power-button then caused "cat" to crash.
The exact failure more seems to vary a bit but variously, you'll get a
segfault in "cat", possible along with some kind of machine check
error, or the machine dies.  I confirmed this behavior both on
zx1-based platforms and on a Tiger.  This used to work fine (well,
last time I tried it was probably a 2.4 kernel, but still...).

I attached the console output that I got when doing this on the tiger.
It looks to me like a more or less random address is being accessed.

The kernel was 2.6.4-rc1.

If you don't have physical access to a machine, I think the bug
can also be triggered by simply hitting Ctrl-C when "cat" is
running.

It's a good thing access to /proc/acpi/events is privileged...

	--david


kernel unaligned access to 0xffffffffffffffff, ip=0xa0000001000f7f30
cat[628]: error during unaligned kernel access
 -1 [1]
CPU 1: SAL log contains CPE error record

Pid: 628, CPU 2, comm:                  cat
psr : 0000101008022018 ifs : 8000000000000308 ip  : [<a0000001000f7f30>]    Not tainted
ip is at kfree+0xb0/0x1c0
unat: 0000000000000000 pfs : 0000000000000288 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 000000000009aa59
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000010039ea50 b6  : a0000001000f2f40 b7  : a00000010000c8c0
f6  : 000000000000000000000 f7  : 1003e0fc0fc0fc0fc0fc1
f8  : 1003e0000000000002490 f9  : 1003e000000000ea008e2
f10 : 1003e00000000367b9beb f11 : 1003e44b831eee7285baf
r1  : a000000100a94e30 r2  : 0000000000000003 r3  : e0000007ffe880f8
r8  : 000000009fffffff r9  : e000000103ccdb50 r10 : e000000103ccdb40
r11 : 00000000003bb5b4 r12 : e0000002fb88fd80 r13 : e0000002fb888008
r14 : 0000000000004000 r15 : 0000000000004000 r16 : e000000100118000
r17 : e0000002fb888eac r18 : 000000000000000f r19 : a0000001008a9b80
r20 : a0000001008a9b80 r21 : 0000000000000018 r22 : a0000001008461d0
r23 : 4652575000000000 r24 : 0000008000000000 r25 : 0000000000000001
r26 : 0000000000004000 r27 : 0000000000004000 r28 : 0000000000004000
r29 : 0000000000000001 r30 : 0000000000000018 r31 : 0000000000000288

Call Trace:
 [<a000000100014a20>] show_stack+0x80/0xa0
 [<a00000010003de20>] die+0x1a0/0x2a0
 [<a000000100043470>] ia64_handle_unaligned+0x1410/0x2600
 [<a00000010000d610>] ia64_prepare_handle_unaligned+0x30/0x60
 [<a00000010000d040>] ia64_leave_kernel+0x0/0x260
 [<a0000001000f7f30>] kfree+0xb0/0x1c0
 [<a00000010039ea50>] acpi_bus_receive_event+0x2d0/0x300
 [<a0000001003ac1a0>] acpi_system_read_event+0xc0/0x2a0
 [<a000000100133040>] vfs_read+0x1c0/0x2e0
 [<a000000100133620>] sys_read+0x60/0xe0
 [<a00000010000cec0>] ia64_ret_from_syscall+0x0/0x20
