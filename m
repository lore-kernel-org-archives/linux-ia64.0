From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 26 Jan 2006 07:24:09 +0000
Subject: Re: [PATCH 8/12] generic hweight{32,16,8}()
Message-Id: <661de9470601252312m1f9c9256peb79451e49fc8662@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com>
	 <20060125113206.GD18584@miraclelinux.com>
	 <20060125200250.GA26443@flint.arm.linux.org.uk>
	 <20060125205907.GF9995@esmail.cup.hp.com>
	 <20060126032713.GA9984@miraclelinux.com>
	 <20060126033613.GG11138@miraclelinux.com>
In-Reply-To: <20060126033613.GG11138@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>
Cc: Grant Grundler <iod00d@hp.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On 1/26/06, Akinobu Mita <mita@miraclelinux.com> wrote:
> This patch introduces the C-language equivalents of the functions below:
> unsigned int hweight32(unsigned int w);
> unsigned int hweight16(unsigned int w);
> unsigned int hweight8(unsigned int w);
>
> HAVE_ARCH_HWEIGHT_BITOPS is defined when the architecture has its own
> version of these functions.
>
> This code largely copied from:
> include/linux/bitops.h
>
> Index: 2.6-git/include/asm-generic/bitops.h
> =================================> --- 2.6-git.orig/include/asm-generic/bitops.h   2006-01-25 19:14:10.000000000 +0900
> +++ 2.6-git/include/asm-generic/bitops.h        2006-01-25 19:14:11.000000000 +0900
> @@ -458,14 +458,38 @@
>  #endif /* HAVE_ARCH_FFS_BITOPS */
>
>
> +#ifndef HAVE_ARCH_HWEIGHT_BITOPS
> +
>  /*
>   * hweightN: returns the hamming weight (i.e. the number
>   * of bits set) of a N-bit word
>   */
>
> -#define hweight32(x) generic_hweight32(x)
> -#define hweight16(x) generic_hweight16(x)
> -#define hweight8(x) generic_hweight8(x)
> +static inline unsigned int hweight32(unsigned int w)
> +{
> +        unsigned int res = (w & 0x55555555) + ((w >> 1) & 0x55555555);
> +        res = (res & 0x33333333) + ((res >> 2) & 0x33333333);
> +        res = (res & 0x0F0F0F0F) + ((res >> 4) & 0x0F0F0F0F);
> +        res = (res & 0x00FF00FF) + ((res >> 8) & 0x00FF00FF);
> +        return (res & 0x0000FFFF) + ((res >> 16) & 0x0000FFFF);
> +}
> +

This can be replaced with

  register int res=w;
  res=res-((res>>1)&0x55555555);
  res=(res&0x33333333)+((res>>2)&0x33333333);
  res=(res+(res>>4))&0x0f0f0f0f;
  res=res+(res>>8);
  return (res+(res>>16)) & 0xff;

Similar optimizations can be applied to the routines below. Please see
http://www-cs-faculty.stanford.edu/~knuth/mmixware.html errata and the code
in mmix-arith.w for the complete set of optimizations and credits.

http://www.jjj.de/fxt/fxtbook.pdf is another inspirational source for
such algorithms.

> +static inline unsigned int hweight16(unsigned int w)
> +{
> +        unsigned int res = (w & 0x5555) + ((w >> 1) & 0x5555);
> +        res = (res & 0x3333) + ((res >> 2) & 0x3333);
> +        res = (res & 0x0F0F) + ((res >> 4) & 0x0F0F);
> +        return (res & 0x00FF) + ((res >> 8) & 0x00FF);
> +}
> +
> +static inline unsigned int hweight8(unsigned int w)
> +{
> +        unsigned int res = (w & 0x55) + ((w >> 1) & 0x55);
> +        res = (res & 0x33) + ((res >> 2) & 0x33);
> +        return (res & 0x0F) + ((res >> 4) & 0x0F);
> +}
> +
> +#endif /* HAVE_ARCH_HWEIGHT_BITOPS */
>
>  #endif /* __KERNEL__ */

Regards,
Balbir
