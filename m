From: Piet/Pete Delaney <piet@sgi.com>
Date: Fri, 22 Mar 2002 02:07:25 +0000
Subject: Re: [Linux-ia64] elf64
Message-Id: <marc-linux-ia64-105590701905327@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905325@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905325@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, Mar 22, 2002 at 12:26:48PM +1100, Keith Owens wrote:
> On Thu, 21 Mar 2002 17:20:30 -0800,=20
> Piet/Pete Delaney <piet@sgi.com> wrote:
> >I was wondering if elf64 is a feature provided in=20
> >recient version of binutils for ia64.
>=20
> Don't understand the question.  All 64 bit machines require elf 64 bit
> support.

HP's gdb Autoconfig classified RedHat ia64 7.2 as a configuration with a 'o=
ldld'
and I thought maybe it was just the autoconfig bdf files that were wrong
so I classified the linuxoldld as a elf64 and got a problem with the
the elf_em.h missing:

-------------------------------------------------------------------------
  ia64*-*-*elf64*)
    targ_defvec=BFd_elf64_ia64_vec
    targ_selvecs=BFd_elf64_ia64_little_header_vec
    ;;
+ ia64-unknown-linuxoldld*)
+   targ_defvec=BFd_elf64_ia64_vec
+   targ_selvecs=BFd_elf64_ia64_little_header_vec
+   ;;
--------------------------------------------------------------------

Unfortunatley that results in:
---------------------------------------------------------------------
cc -c -DHOST_IA64    -I. -I. -I./../include   elf64-ia64.c
elf64-ia64.c:43:20: elf_em.h: No such file or directory
make[1]: *** [elf64-ia64.o] Error 1
make[1]: Leaving directory `/home/piet/src/kwdb/src/bfd'
make: *** [all-bfd] Error 2
-------------------------------------------------------------------------

Looks like David Mosberger version of bdf/elf64-ia64.c has replaced
the Copyright 1993 version in HP's code.

Looks like I picked up code that's very out of date.

-piet

