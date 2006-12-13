From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 13 Dec 2006 10:02:48 +0000
Subject: Re: test_and_set_bit implementation
Message-Id: <457FCFC8.40709@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <457EC42C.90002@bull.net>
In-Reply-To: <457EC42C.90002@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote:

> The original code and your rewrite both access memory twice in the loop.
> Why don't we do it with one memory reference per loop instead?
>=20
> {
> 	CMPXCHG_BUGCHECK_DECL
>=20
> 	u32 *m =3D (u32 *)addr + (nr >> 5);
> 	u32 bit =3D 1 << (nr & 31);
>=20
> 	u32 old =3D *m;
> 	while (!(old & bit)) {
> 		u32 new =3D old | bit;
> 		u32 prev =3D cmpxchg_acq(m, old, new);
> 		CMPXCHG_BUGCHECK(m);
> 		if (prev =3D old)
> 			return 1;
> 		old =3D prev;
> 	}
>=20
> 	return 0;
> }
>=20
> Looking at the disassembly of grab_block() in fs/ext2/balloc.c, I don't
> see much difference.  The ld4.acq turns into a regular ld4 (because
> 'm' is no longer tagged as volatile), and is hoisted out of the loop.
> Interestingly, gcc chooses to reorder the tests, and make the loop four
> bundles long instead of three, but will 'goto repeat' in two bundles
> instead of four.  Using likely()/unlikely() doesn't persuade gcc to
> change the order of the two branches, so I assume it actually is better
> to do it this way.

I like this code with the following slight modifications:
- let's keep "m" as pointer to volatile
- let's keep on using "__u32" types
- not sure we need "new"
- return the old bit

	volatile __u32 *m =3D (volatile __u32 *)addr + (nr >> 5);
	__u32 bit =3D 1 << (nr & 31);

	__u32 old =3D *m;
	while (!(old & bit)) {
		__u32 prev =3D cmpxchg_acq(m, old, old | bit);
		CMPXCHG_BUGCHECK(m);
		if (prev =3D old)
			return 0;
		old =3D prev;
	}
	return 1;

It compiles to:

   0:         and r151,r32
   6:         mov r14=3D1
   c:         extr r32=3Dr32,5,27;;
  10:         shladd r18=3Dr32,2,r33;;
  16:         ld4.acq r16=3D[r18]
  1c:         shl r17=3Dr14,r15;;
  20:         and r14=3Dr17,r16;;
  26:         nop.m 0x0
  2c:         cmp4.eq p7,p6=3D0,r14
  30:         nop.b 0x0
  36:         nop.b 0x0
  3c:   (p06) br.cond.dpnt.few a0 <+0xa0>
  40:         nop.m 0x0
  46:         zxt4 r14=3Dr16
  4c:         nop.b 0x0;;
  50:         mov.m ar.ccv=3Dr14;;
  56:         nop.m 0x0
  5c:         or r14=3Dr17,r16
  60:         nop.m 0x0;;
  66:         cmpxchg4.acq r14=3D[r18],r14,ar.ccv
  6c:         nop.i 0x0;;
  70:         cmp4.eq p7,p6=3Dr14,r16
  76:         nop.f 0x0
  7c:         and r15=3Dr17,r14
  80:         mov r16=3Dr14
  86:         nop.f 0x0
  8c:   (p07) br.cond.dpnt.few b0 <+0xb0>;;
  90:         nop.m 0x0
  96:         cmp4.eq p7,p6=3D0,r15
  9c:   (p07) br.cond.dptk.few 40 <+0x40>
  a0:         nop.m 0x0
  a6:         mov r8=3D1
  ac:         br.ret.sptk.many b0;;
  b0:         nop.m 0x0
  b6:         mov r8=3Dr0
  bc:         br.ret.sptk.many b0;;

It seems to be o.k., thanks.

Zolt=E1n Menyh=E1rt


