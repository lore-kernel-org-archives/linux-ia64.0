From: Christoph Rohland <cr@sap.com>
Date: Tue, 09 May 2000 17:56:40 +0000
Subject: Re: [Linux-ia64] ld failure
Message-Id: <marc-linux-ia64-105590678205076@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205047@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205047@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Uros Prestor <uros@turbolinux.com> writes:

> Christoph Rohland wrote:
>=20
> > This problem is solved with the new gnupro toolkit included on TL
> > 0505. (Of course I get now an =EDllegal instruction'when running the
> > executable due to the missing brl emulation in the kernel.)
>=20
> Try the new kernel RPM available on our update site:
>=20
>      ftp://ftp.turbolinux.com/pub/ia64/0505/updates/RPMS/ia64/kernel-2.3.=
99-19.ia64.rpm

This now does not generate an ill instruction, but a seg fault in:

$ gdb dw
GNU gdb 20000204
Copyright 2000 Free Software Foundation, Inc.
GDB is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain condition=
s.
Type "show copying" to see the conditions.
There is absolutely no warranty for GDB.  Type "show warranty" for details.
This GDB was configured as "ia64-unknown-linux"...
(gdb) r
Starting program: /bas/46B/gen/opt/linuxia64/dw

Program received signal SIGSEGV, Segmentation fault.
0x4000000001a7e880 in __do_global_ctors_aux ()
(gdb) bt
#0  0x4000000001a7e880 in __do_global_ctors_aux ()
#1  0x4000000000004a20 in _init ()
(gdb) =20

Greetings
		Christoph


