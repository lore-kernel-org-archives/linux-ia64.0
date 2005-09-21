From: Jack Steiner <steiner@sgi.com>
Date: Wed, 21 Sep 2005 18:23:43 +0000
Subject: ia64 dispersal analysis capability
Message-Id: <20050921182143.GA30873@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

In 2002, Gary Hade posted a patch to binutils that added dispersal
analysis to the output of objdump. Does anyone know what happened to
the patch? Is there another tool that provides the same information?

I've found the tool very useful for providing insight into IA64
code scheduling.=20

Example:

4000000000002f60 <main>:
4000000000002f60:       00 40 39 14 80 05          0                 [MII] =
      alloc r40=3Dar.pfs,14,10,0
4000000000002f66:       40 02 00 00 42 c0          0                       =
      mov r36=3Dr0
4000000000002f6c:       01 0b 00 90                0                       =
      addl r14H,r1
4000000000002f70:       01 30 81 03 04 24          0                 [MII] =
      addl r38`8,r1
4000000000002f76:       90 02 04 00 42 e0          1 R[I0,I1]              =
      mov r41=3Dr1
4000000000002f7c:       04 00 c4 00                1                       =
      mov r39=B0;;
4000000000002f80:       00 78 00 1c 18 10          2 S               [MII] =
      ld8 r15=3D[r14]
4000000000002f86:       e0 08 00 00 48 00          2                       =
      mov r14=3D1
4000000000002f8c:       00 00 04 00                2                       =
      nop.i 0x0
4000000000002f90:       0a 50 01 4c 18 10          2                 [MMI] =
      ld8 r42=3D[r38];;
4000000000002f96:       00 70 3c 20 23 00          5 S L[r15] L[r15]       =
      st4 [r15]=3Dr14
4000000000002f9c:       00 00 04 00                5                       =
      nop.i 0x0
4000000000002fa0:       11 00 00 00 01 00          5                 [MIB] =
      nop.m 0x0
4000000000002fa6:       00 00 00 02 00 00          5                       =
      nop.i 0x0
4000000000002fac:       c8 fd ff 58                5                       =
      br.call.sptk.many b0@00000000002d60 <scaled_atol>;;
4000000000002fb0:       0b 08 00 52 00 21          6                 [MMI] =
      mov r1=3Dr41;;
4000000000002fb6:       f0 40 06 0a 48 c0          7 S                     =
      addl r15q2,r1
4000000000002fbc:       81 ed ef 9f                7                       =
      addl r14=3D-552,r1;;
4000000000002fc0:       09 28 01 1e 00 21          8 S               [MMI] =
      mov r37=3Dr15
4000000000002fc6:       30 02 38 00 42 00          8                       =
      mov r35=3Dr14
4000000000002fcc:       00 00 04 00                8                       =
      nop.i 0x0;;
4000000000002fd0:       00 00 20 4a 98 11          9 S               [MII] =
      st8 [r37]=3Dr8
4000000000002fd6:       00 00 00 02 00 00          9                       =
      nop.i 0x0
4000000000002fdc:       00 00 04 00                9                       =
      nop.i 0x0
4000000000002fe0:       00 50 01 40 00 21          9                 [MII] =
      mov r42=3Dr32
4000000000002fe6:       b0 02 84 00 42 80         10 R[I0,I1]              =
      mov r43=3Dr33

--=20
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


