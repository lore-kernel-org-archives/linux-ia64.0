From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 26 Jan 2006 07:17:47 +0000
Subject: Re: [PATCH 9/12] generic hweight64()
Message-Id: <661de9470601252305n65c32059y5ba72334d422cf01@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com>
	 <20060125113206.GD18584@miraclelinux.com>
	 <20060125200250.GA26443@flint.arm.linux.org.uk>
	 <20060125205907.GF9995@esmail.cup.hp.com>
	 <20060126032713.GA9984@miraclelinux.com>
	 <20060126033652.GH11138@miraclelinux.com>
In-Reply-To: <20060126033652.GH11138@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>
Cc: Grant Grundler <iod00d@hp.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On 1/26/06, Akinobu Mita <mita@miraclelinux.com> wrote:
> This patch introduces the C-language equivalent of the function:
> unsigned long hweight64(__u64 w);
>
> HAVE_ARCH_HWEIGHT64_BITOPS is defined when the architecture has its own
> version of these functions.
>
> This code largely copied from:
> include/linux/bitops.h
>
> Index: 2.6-git/include/asm-generic/bitops.h
> =================================> --- 2.6-git.orig/include/asm-generic/bitops.h   2006-01-25 19:14:11.000000000 +0900
> +++ 2.6-git/include/asm-generic/bitops.h        2006-01-25 19:14:11.000000000 +0900
> @@ -491,6 +491,25 @@
>
>  #endif /* HAVE_ARCH_HWEIGHT_BITOPS */
>
> +#ifndef HAVE_ARCH_HWEIGHT64_BITOPS
> +
> +static inline unsigned long hweight64(__u64 w)
> +{
> +#if BITS_PER_LONG < 64
> +       return hweight32((unsigned int)(w >> 32)) + hweight32((unsigned int)w);
> +#else
> +       u64 res;
> +       res = (w & 0x5555555555555555ul) + ((w >> 1) & 0x5555555555555555ul);

This can be replaced with

res = (w-((w >> 1) & 0x5555555555555555ul));

> +       res = (res & 0x3333333333333333ul) + ((res >> 2) & 0x3333333333333333ul);
> +       res = (res & 0x0F0F0F0F0F0F0F0Ful) + ((res >> 4) & 0x0F0F0F0F0F0F0F0Ful);

res = (res+(res>>4))&0x0F0F0F0F0F0F0F0Ful;

> +       res = (res & 0x00FF00FF00FF00FFul) + ((res >> 8) & 0x00FF00FF00FF00FFul);
> +       res = (res & 0x0000FFFF0000FFFFul) + ((res >> 16) & 0x0000FFFF0000FFFFul);
> +       return (res & 0x00000000FFFFFFFFul) + ((res >> 32) & 0x00000000FFFFFFFFul);
> +#endif
> +}
> +
> +#endif /* HAVE_ARCH_HWEIGHT64_BITOPS */
> +
>  #endif /* __KERNEL__ */
>
>  #endif /* _ASM_GENERIC_BITOPS_H */
> -

Please see Don Knuth's MMIXWare for more credits and improvements to this
algorithm

Balbir
