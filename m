From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 03 Sep 2003 18:25:40 +0000
Subject: 2.4.21 + 64K pagesize  == BOOM
Message-Id: <marc-linux-ia64-106261419520719@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Someone here tried to build a 2.4.21 kernel with 64k
page size, but found that the system reset during boot.

Some tracking showed that the problem was an MCA when
the kernel jumped to 0xf000eef3000c0100.  Further tracking
showed that the jump came from probe_hwif().  Here's some
disassembled code (showing just the "br.call" before and
after the fatal jump for context):

e0000000046fb93c: (p03) br.call.dpnt.many b0=E0000000046fde00 <probe_cmos_f=
or_drives>;;
e0000000046fb96c:       br.call.sptk.many b0=E0000000046fb580 <hwif_check_r=
egions>;;
e0000000046fba7c:       br.call.sptk.many b0=E000000004476ba0 <printk>;;
e0000000046fbabc: (p17) br.call.dpnt.many b0=E00000000440dc20 <disable_irq>=
;;
e0000000046fbbdc:       br.call.sptk.many b0=E0000000044b5480 <kmalloc>;;
e0000000046fbc1c:       br.call.sptk.many b0=E000000004476ba0 <printk>
e0000000046fbc8c:       br.call.sptk.many b0=E0000000046fb720 <hwif_registe=
r>
e0000000046fbd3c: (p17) br.call.dpnt.many b0=E00000000440de00 <enable_irq>;;

e0000000046fbe10:       ld8 r19=3D[r40];;  // get 0x0 into r19
e0000000046fbe16:       ld8 r18=3D[r19],8  // get 0xf000eef3000c0100 into r=
18
e0000000046fbe1c:       nop.i 0x0;;
e0000000046fbe20:       ld8 r1=3D[r19]
e0000000046fbe26:       mov b7=3Dr18
e0000000046fbe2c:       br.call.sptk.many b0=B7;; // JUMP TO 0xf000eef3000c=
0100 BOOM!

e0000000046fbe5c:       br.call.sptk.many b0=B7;;
e0000000046fbe8c:       br.call.sptk.many b0=B7;;
e0000000046fbedc:       br.call.sptk.many b0=E000000004476ba0 <printk>;;
e0000000046fbf0c:       br.call.sptk.many b0=B7;;
e0000000046fbfec:       br.call.sptk.many b0=B7;;
e0000000046fc01c:       br.call.sptk.many b0=E00000000470f1e0 <ide_delay_50=
ms>;;

I'm not sure why the dereference 0x0 didn't fault.

Building with CONFIG_BLK_DEV_IDE=3Dn avoids this problem.

Anyone know what's going on here?

-Tony

