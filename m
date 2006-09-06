From: Linus Torvalds <torvalds@osdl.org>
Date: Wed, 06 Sep 2006 20:20:59 +0000
Subject: Re: [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <Pine.LNX.4.64.0609061314430.27779@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org>
In-Reply-To: <44FC193C.4080205@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kirill Korotaev <dev@openvz.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fernando Vazquez <fernando@oss.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org, stable@kernel.org, xemul@openvz.org, devel@openvz.org



On Mon, 4 Sep 2006, Kirill Korotaev wrote:
> 
> +#ifdef __KERNEL__
> +#define arch_mmap_check	ia64_mmap_check
> +#ifndef __ASSEMBLY__
> +int ia64_mmap_check(unsigned long addr, unsigned long len,
> +		unsigned long flags);
> +#endif
> +#endif

Btw, is there some reason for the __ASSEMBLY__ check?

I'm not seeing any kernel users that could care, a quick

	git grep 'mman\.h' -- '*.[sS]'

doesn't trigger anything, and the other header files that include this 
seem to all either be mman.h themselves, or have things like structure 
declarations etc that wouldn't work for any non-C source anyway.

But maybe I missed some.

I'd rather not have more of those '#ifndef __ASSEMBLY__' than necessary.

		Linus
