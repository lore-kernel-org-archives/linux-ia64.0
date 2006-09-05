From: Kyle McMartin <kyle@parisc-linux.org>
Date: Tue, 05 Sep 2006 11:39:39 +0000
Subject: Re: [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <20060905113939.GA5130@tachyon.int.mcmartin.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org>
In-Reply-To: <44FC193C.4080205@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kirill Korotaev <dev@openvz.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Fernando Vazquez <fernando@oss.ntt.co.jp>, "David S. Miller" <davem@davemloft.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org, stable@kernel.org, xemul@openvz.org, devel@openvz.org

On Mon, Sep 04, 2006 at 04:17:00PM +0400, Kirill Korotaev wrote:
> --- a/include/asm-generic/mman.h
> +++ b/include/asm-generic/mman.h
> @@ -39,4 +39,10 @@ #define MADV_DOFORK	11		/* do inherit ac
> #define MAP_ANON	MAP_ANONYMOUS
> #define MAP_FILE	0
> 
> +#ifdef __KERNEL__
> +#ifndef arch_mmap_check
> +#define arch_mmap_check(addr, len, flags)	(0)
> +#endif
> +#endif
> +
> #endif

This breaks all arches that don't use asm-generic/mman.h, and that you
didn't add arch_mmap_check to asm/mman.h for.
