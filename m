From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 28 Oct 2003 00:57:01 +0000
Subject: ipchains on 2.6: dangerous to your kernel's health
Message-Id: <marc-linux-ia64-106730288604480@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

As I mentioned earlier, ipchains seems to be having some problems in
the 2.6 kernel.  Since iptables is working fine, perhaps we should
just forget about ipchains, but I was able to reproduce the bug with
ipchains now and collect a useful backtrace, in case someone does
care.

The setup is as follows:

 - client machine on a private (192.168...) subnet with its traffic
   routed through a Linux NaT box

 - NaT box running 2.6.0 (e.g., 2.6.0-test9) with this ipchains setup:

     ipchains -A forward -s 192.168.10.0/24 -d 0/0 -j MASQ

On the client, start mozilla and then visit various web sites.  It's a
bit difficult to predict when the NaT box will crash, but I usually
can reproduce it in 1-5 minutes by surfing various sites at the net
(e.g., cnn.com, linuxtoday.org, amazon.com, and stuff like that).
Independent of what web page triggers the crash, the tombstone always
looks as attached (i.e., crash in ip_nat_setup_info).

Inlining hides the source of the real problem: even though the crash
is reported for ip_nat_setup_info(), the root cause appears to be
find_appropriate_src().  I think LIST_FIND() in that routine ends up
picking up a pointer list-pointer (perhaps it's running past the end
of the list).

Anyhow, since iptables doesn't seem to suffer from this problem, I'm
going to assume ipchains is just not worth it anymore.  I'll post
something on the lkml to see what the feeling is there.

	--david
--------------------------------------------------
Unable to handle kernel paging request at virtual address 0000000000100110
swapper[0]: Oops 8813272891392 [1]

Pid: 0, CPU 0, comm:              swapper
psr : 0000101008026018 ifs : 80000000000024cd ip  : [<a00000020009f010>]   =
 Tainted: GF=20
ip is at ip_nat_setup_info+0x210/0x1980 [ipchains]
unat: 0000000000000000 pfs : 00000000000024cd rsc : 0000000000000003
rnat: 000000000000038b bsps: 0000000000000003 pr  : 80000000df5aa565
ldrs: 0000000000000000 ccv : 0000000000000002 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000020009f0c0 b6  : a000000100003320 b7  : a00000020009af00
f6  : 0fff38a1dac6008a1da0b f7  : 0ffe2eee2400000000000
f8  : 1003e000000000b0aab51 f9  : 1003efffffffffffff12c
f10 : 1000ebea0ffcc34df5afb f11 : 1003e0000000000000ed1
r1  : a000000200294000 r2  : 0000000000000011 r3  : a0000002000cc000
r8  : a0000002000afab0 r9  : 0000000000000011 r10 : 000000000b0aa8c0
r11 : 0000000000000280 r12 : e0000000047d3ae0 r13 : e0000000047cc000
r14 : a0000002000afac8 r15 : 00000000c0a80a0b r16 : e0000000047d3ba8
r17 : a0000002000dad10 r18 : a0000002000cc000 r19 : 0000000000000000
r20 : 0000000000000011 r21 : e000000036b4212e r22 : 0000000000100110
r23 : 000000000b0aa8c0 r24 : 0000000000000280 r25 : 0000000000000280
r26 : e00002800b0aa8c0 r27 : 001135000430000f r28 : 00000000e0000280
r29 : 0000000000113500 r30 : 000000000430000f r31 : 000000000b0aa8c0

Call Trace:
 [<a00000010001da40>] show_stack+0x80/0xa0
                                sp=E0000000047d36b0 bsp=E0000000047cd810
 [<a000000100040740>] die+0x140/0x240
                                sp=E0000000047d3880 bsp=E0000000047cd7c8
 [<a000000100063c80>] ia64_do_page_fault+0xb80/0xba0
                                sp=E0000000047d3880 bsp=E0000000047cd760
 [<a000000100014f60>] ia64_leave_kernel+0x0/0x260
                                sp=E0000000047d3910 bsp=E0000000047cd760
 [<a00000020009f010>] ip_nat_setup_info+0x210/0x1980 [ipchains]
                                sp=E0000000047d3ae0 bsp=E0000000047cd4f0
 [<a00000020009e5c0>] do_masquerade+0x440/0x560 [ipchains]
                                sp=E0000000047d3b40 bsp=E0000000047cd480
 [<a00000020009be20>] fw_in+0x480/0x720 [ipchains]
                                sp=E0000000047d3bf0 bsp=E0000000047cd438
 [<a0000001005beec0>] nf_iterate+0x140/0x240
                                sp=E0000000047d3c00 bsp=E0000000047cd3d8
 [<a0000001005c05e0>] nf_hook_slow+0xc0/0x300
                                sp=E0000000047d3c00 bsp=E0000000047cd360
 [<a0000001005dac50>] ip_forward+0x5b0/0x700
                                sp=E0000000047d3c10 bsp=E0000000047cd310
 [<a0000001005d64a0>] ip_rcv_finish+0x420/0x640
                                sp=E0000000047d3c10 bsp=E0000000047cd2d0
 [<a0000001005c0790>] nf_hook_slow+0x270/0x300
                                sp=E0000000047d3c20 bsp=E0000000047cd258
 [<a0000001005d7150>] ip_rcv+0xa90/0xb40
                                sp=E0000000047d3c30 bsp=E0000000047cd200
 [<a0000001005a9fa0>] netif_receive_skb+0x5a0/0x5c0
                                sp=E0000000047d3c40 bsp=E0000000047cd1a8
 [<a0000001005aa0d0>] process_backlog+0x110/0x300
                                sp=E0000000047d3c40 bsp=E0000000047cd138
 [<a0000001005a67c0>] net_rx_action+0x160/0x360
                                sp=E0000000047d3c40 bsp=E0000000047cd0f0
 [<a0000001000a1cf0>] do_softirq+0x250/0x2c0
                                sp=E0000000047d3c50 bsp=E0000000047cd070
 [<a00000010001a8b0>] do_IRQ+0x3f0/0x440
                                sp=E0000000047d3c50 bsp=E0000000047cd020
 [<a00000010001af90>] ia64_handle_irq+0x70/0x140
                                sp=E0000000047d3c50 bsp=E0000000047ccfe8
 [<a000000100014f60>] ia64_leave_kernel+0x0/0x260
                                sp=E0000000047d3c50 bsp=E0000000047ccfe8
 [<a00000010001d620>] cpu_idle+0xe0/0x220
                                sp=E0000000047d3e20 bsp=E0000000047ccfa8
 [<a000000100790c00>] start_kernel+0x3e0/0x5e0
                                sp=E0000000047d3e20 bsp=E0000000047ccf40
 [<a000000100010290>] _start+0x290/0x2b0
                                sp=E0000000047d3e30 bsp=E0000000047ccf40
 <0>Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing
