From: "H . J . Lu" <hjl@valinux.com>
Date: Thu, 11 Jan 2001 21:26:01 +0000
Subject: [Linux-ia64] The 1117 snapshot alignment bug
Message-Id: <marc-linux-ia64-105590693005029@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I got a kernel unaligned access bug:

cp[31284]: Unaligned reference while in kernel
 30

psr : 00001010080a6038 ifs : 8000000000000813 ip  : [<e00000000063d170>]
unat: 0000000000000000 pfs : 000000000000040e rsc : 0000000000000003
rnat: 0000000000000008 bsps: 000000000001003e pr  : 0000000000190293
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8270033f
b0  : e000000000633b40 b6  : e00000000063d0e0 b7  : e000000000521140
f6  : 0fff3fffffffff0000000 f7  : 0ffe68000000000000000
f8  : 1000a8000000000000000 f9  : 1000a8000000000000000
r1  : e000000000b85a80 r2  : 0000000000000001 r3  : e000000008f3fbc8
r8  : e00000000063d0e0 r9  : 0000000000000309 r10 : 0000000000000000
r11 : 0000000000190093 r12 : e000000008f3fbf0 r13 : e000000008f38000
r14 : 000000000000001c r15 : e00000002c9c4740 r16 : e000000008f3fcd4
r17 : e000000008f3fcb8 r18 : e000000008f3fcc0 r19 : e000000008f3fcf0
r20 : e000000008f3fcc8 r21 : e000000008f3fc88 r22 : e0000000296a9028
r23 : 0000000000000c00 r24 : e0000000296a91f8 r25 : 0000000000000c00
r26 : e0000000296a9208 r27 : e000000008f3fd84 r28 : e000000008f3fdc8
r29 : e000000008f3fd60 r30 : 0000000000000002 r31 : 0000000000000000
r32 : 0000000000000000 r33 : 0000000000000000 r34 : 0000000000000000
r35 : 0000000000000000 r36 : 0000000000000000 r37 : 0000000000000000
r38 : 0000000000000000 r39 : 0000000000000000 r40 : 0000000000000000
r41 : 0000000000000000 r42 : 0000000000000000 r43 : 0000000000000000
r44 : 0000000000000000 r45 : 0000000000000000 r46 : 0000000000000000
r47 : 0000000000000000 r48 : 0000000000000000 r49 : 0000000000000000
r50 : 0000000000000000

when I copied over NFS. I believe it is a compiler bug.

# gcc al.c
# a.out
a.out(466): unaligned access to 0x80000ffffffff8bc, ip=0x4000000000000760
0x80000ffffffff890
0x80000ffffffff89c: 4
4

The problem is

  struct bar x = { b->f4, 0, {0, 0} };

gcc uses

st8 [rX] = r0

for {0, 0}. But st8 requires 8 byte aligment while

  unsigned int f6 [2];

has 4 byte aligment.

BTW, nfs3_proc_create in fs/nfs/nfs3proc.c got miscompiled.


H.J.
----al.c---
#include <stdio.h>

enum bool { false, true };

struct bar
{
  void *f4;
  enum bool f5;
  unsigned int f6 [2];
};

struct bar
f_bar (struct bar *b)
{
  struct bar x = { b->f4, 0, {0, 0} };
  printf ("%p\n", &x); 
  printf ("%p: %d\n", &x.f6, ((long) (&x.f6)) & 0x7); 
  printf ("%d\n", __alignof__ (x.f6)); 
  return x;
}

main ()
{
  struct bar x;
  x = f_bar (&x);
}

