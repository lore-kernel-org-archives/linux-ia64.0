From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 07 May 2012 17:58:53 +0000
Subject: RE: getcpu() returns EFAULT when called via the vdso
Message-Id: <3908561D78D1C84285E8C5FCA982C28F192D61E6@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201205061645.24398.vapier@gentoo.org>
In-Reply-To: <201205061645.24398.vapier@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


the disassembly of the sched_getcpu() code at runtime looks like:
   0x2000000000203940 <+0>:     [MMI]       alloc r32=3Dar.pfs,9,1,0
   0x2000000000203941 <+1>:                 adds r14=3D8,r13
   0x2000000000203942 <+2>:                 mov r33=3Dr12;;
   0x2000000000203950 <+16>:    [MMI]       ld8 r14=3D[r14]
   0x2000000000203951 <+17>:                nop.m 0x0
   0x2000000000203952 <+18>:                mov r15=1304
   0x2000000000203960 <+32>:    [MII]       mov r35=3Dr0  <<<<<<<<<<<<<<<<<=
<<
   0x2000000000203961 <+33>:                mov r34=3Dr0;;<<<<<<<<<<<<<<<<<=
<<
   0x2000000000203962 <+34>:                mov b7=3Dr14;;
   0x2000000000203970 <+48>:    [MIB]       nop.m 0x0
   0x2000000000203971 <+49>:                nop.i 0x0
   0x2000000000203972 <+50>:                br.call.sptk.many b6=B7;;

When the "br.call" is executed, we flip to the new register
frame and r34/r35 in the sched_getcpu() frame become r32/r33
in the new frame.

So you get -EFAULT because the VDSO tries to dereference a NULL
pointer for each of the *cpu and *node arguments.

-Tony
