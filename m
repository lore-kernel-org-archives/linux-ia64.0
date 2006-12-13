From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 13 Dec 2006 12:29:52 +0000
Subject: Re: test_and_set_bit implementation
Message-Id: <20061213122952.GM21070@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <457EC42C.90002@bull.net>
In-Reply-To: <457EC42C.90002@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Dec 13, 2006 at 11:02:48AM +0100, Zoltan Menyhart wrote:
> I like this code with the following slight modifications:
> - let's keep "m" as pointer to volatile

Why?  What benefit is there to doing an ld4.acq instead of a plain ld4?

> - let's keep on using "__u32" types

Why be so ugly?

> - not sure we need "new"

Good idea.

> - return the old bit

I don't understand what you mean here.

> 	volatile __u32 *m = (volatile __u32 *)addr + (nr >> 5);
> 	__u32 bit = 1 << (nr & 31);
> 
> 	__u32 old = *m;
> 	while (!(old & bit)) {
> 		__u32 prev = cmpxchg_acq(m, old, old | bit);
> 		CMPXCHG_BUGCHECK(m);
> 		if (prev = old)
> 			return 0;
> 		old = prev;
> 	}
> 	return 1;
> 
> It compiles to:
> 
>   0:         and r151,r32
>   6:         mov r14=1
>   c:         extr r32=r32,5,27;;
>  10:         shladd r18=r32,2,r33;;
>  16:         ld4.acq r16=[r18]
>  1c:         shl r17=r14,r15;;
>  20:         and r14=r17,r16;;
>  26:         nop.m 0x0
>  2c:         cmp4.eq p7,p6=0,r14
>  30:         nop.b 0x0
>  36:         nop.b 0x0
>  3c:   (p06) br.cond.dpnt.few a0 <+0xa0>
>  40:         nop.m 0x0
>  46:         zxt4 r14=r16
>  4c:         nop.b 0x0;;
>  50:         mov.m ar.ccv=r14;;
>  56:         nop.m 0x0
>  5c:         or r14=r17,r16
>  60:         nop.m 0x0;;
>  66:         cmpxchg4.acq r14=[r18],r14,ar.ccv
>  6c:         nop.i 0x0;;
>  70:         cmp4.eq p7,p6=r14,r16
>  76:         nop.f 0x0
>  7c:         and r15=r17,r14
>  80:         mov r16=r14
>  86:         nop.f 0x0
>  8c:   (p07) br.cond.dpnt.few b0 <+0xb0>;;
>  90:         nop.m 0x0
>  96:         cmp4.eq p7,p6=0,r15
>  9c:   (p07) br.cond.dptk.few 40 <+0x40>
>  a0:         nop.m 0x0
>  a6:         mov r8=1
>  ac:         br.ret.sptk.many b0;;
>  b0:         nop.m 0x0
>  b6:         mov r8=r0
>  bc:         br.ret.sptk.many b0;;
> 
> It seems to be o.k., thanks.
> 
> Zolt?n Menyh?rt
> 
