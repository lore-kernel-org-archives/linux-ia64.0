From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 16 Oct 2002 01:16:08 +0000
Subject: Re: [Linux-ia64] Re: loading a kernel module
Message-Id: <marc-linux-ia64-105590709805167@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805162@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805162@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On 15 Oct 2002 14:57:07 -0400,=20
Jim Wilson <wilson@redhat.com> wrote:
>You can get brl instructions by changing "#undef USE_BRL" to "#define USE_=
BRL"
>in the BINUTILS bfd/elfxx-ia64.c file.  I believe that is the change that =
went
>into the RHL AS toolchain.  Then write a large enough program, so that you
>have a call site that is far enough away from its call target to require b=
rl.

You don't need a large program.  The test object from Christian Hildner
is about as small as it gets and it still uses brl.  Christian, please
post the source of the test object to the list.

0000000000000000 <dummy>:
   0:   1d 40 00 00 00 21       [MFB]       mov r8=3Dr0
   6:   00 00 00 02 00 80                   nop.f 0x0
   c:   08 00 84 00                         br.ret.sptk.many b0;;

0000000000000010 <init_module>:
  10:   01 10 11 06 80 05       [MII]       alloc r34=3Dar.pfs,4,3,0
                        12: LTOFF22     .rodata
  16:   10 02 00 62 00 60                   mov r33=B0
  1c:   04 08 00 90                         addl r35=3D0,r1;;
  20:   1d 18 01 46 18 10       [MFB]       ld8 r35=3D[r35]
                        22: PCREL21B    printk
  26:   00 00 00 02 00 00                   nop.f 0x0
  2c:   08 00 00 50                         br.call.sptk.many b0  <init_mod=
ule+0x10>;;
  30:   05 00 00 00 01 00       [MLX]       nop.m 0x0
                        32: PCREL60B    dummy
        ...
  3e:   00 c0 00 40                         brl.few 30 <init_module+0x20>;;
  42:   00 00 00 21 00 10       [MII]       mov r8=3Dr0
  48:   01 55 00 00 10 0a                   mov.i ar.pfs=3Dr34
  4e:   00 07 1d 00                         mov b0=3Dr33
  52:   00 00 01 00 00 00       [MFB]       nop.m 0x0
  58:   00 02 00 80 08 00                   nop.f 0x0
  5e:   84 00 01 10                         br.ret.sptk.many b0;;


