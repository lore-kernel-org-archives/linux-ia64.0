From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Fri, 03 Nov 2006 00:44:32 +0000
Subject: RE: ia64: What the stack trace of a slave cpu kdump should save?
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086B0F@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454A3D93.8090006@sgi.com>
In-Reply-To: <454A3D93.8090006@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Jay Lan
> Sent: 2006=C4=EA11=D4=C23=C8=D5 2:49
> To: fastboot; Linux-IA64
> Subject: ia64: What the stack trace of a slave cpu kdump should save?
>=20
> Hi,
>=20
> I have a vmcore created by NMI on an SN. The gdb backtrace
> showed the slave cpu as below:
>=20
> # gdb vmlinux vmcore-nmi-10
> GNU gdb 6.4
> Copyright 2005 Free Software Foundation, Inc.
> GDB is free software, covered by the GNU General Public License, and you =
are
> welcome to change it and/or distribute copies of it under certain
> conditions.
> Type "show copying" to see the conditions.
> There is absolutely no warranty for GDB.  Type "show warranty" for detail=
s.
> This GDB was configured as "ia64-suse-linux"...Using host libthread_db
> library "/lib/libthread_db.so.1".
>=20
> #0  crash_save_this_cpu () at arch/ia64/kernel/crash.c:57
>=20
> warning: Source file is more recent than executable.
> 57              memcpy(buf, name, note->n_namesz);
> (gdb) bt
> #0  crash_save_this_cpu () at arch/ia64/kernel/crash.c:57
> #1  0xa00000010005f580 in kdump_cpu_freeze (info=3D<value optimized out>,
>     arg=3D0x1) at arch/ia64/kernel/crash.c:166
> #2  0xa00000010000c9f0 in unw_init_running () at include/linux/bitmap.h:2=
37
> #3  0xa00000010005ef70 in kdump_init_notifier (self=3D0xa000000100b47d78,
>     val=3D<value optimized out>, data=3D0xe000003007157b70)
>     at arch/ia64/kernel/crash.c:217
> #4  0xa0000001000cf0d0 in notifier_call_chain (nl=3D0xe000003014bcb3f8,
> val=13,
>     v=3D0xe000003007157b70) at kernel/sys.c:144
> #5  0xa0000001000cf170 in atomic_notifier_call_chain
> (nh=3D0xe000003014bcb3f0,
>     val!, v=3D0xe000003007157b70) at kernel/sys.c:229
> #6  0xa000000100048480 in ia64_init_handler (regs=3D0xe000003007157e40,
>     sw=3D<value optimized out>, sos=3D<value optimized out>)
>     at include/asm/kdebug.h:88
> #7  0xa0000001000493a0 in ia64_os_init_virtual_begin ()
>     at include/asm/kdebug.h:88
> (gdb)
>=20
> It is the stack _after_ NMI is triggered. Is this supposed to be?
> What do you see on other (ie not SN) ia64 platforms?
>=20
 Yes, this is the stack on all other platforms..,=20
=20
 You may call it INIT instead of NMI because NMI is another kind of interru=
pt that can be masked by psr.i...
 Kdump construct an additional switch stack frame on top of current stack t=
hus crash tool can do its unwind from that.
 Kdump also capture ip, sp, bsp and other register related to current stack=
 frame to help gdb to unwind the stack.
 What you see is the stack of INIT , you may use crash tools to back trace =
stack of other process.
 However INIT can break CPU in any context include PROM code, so it is not =
possible to back trace the stack of INIT happening..

Thanks
Zou Nan hai
