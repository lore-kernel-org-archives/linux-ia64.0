From: Andrew Morton <akpm@osdl.org>
Date: Thu, 30 Nov 2006 01:21:12 +0000
Subject: Re: Resolve name clash in 2.6.19-rc6-mm2 by naming
Message-Id: <20061129172112.2d9ddfcf.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0611291651530.18636@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611291651530.18636@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 29 Nov 2006 16:53:35 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> There is a name clash with ia64 arch code in Andrew's tree. Rename
> 
> is_avialable_memory to is_memory_available to avoid the clash.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.19-rc6-mm2/arch/ia64/kernel/efi.c
> =================================> --- linux-2.6.19-rc6-mm2.orig/arch/ia64/kernel/efi.c	2006-11-29 18:36:28.879625138 -0600
> +++ linux-2.6.19-rc6-mm2/arch/ia64/kernel/efi.c	2006-11-29 18:41:43.882576353 -0600
> @@ -225,7 +225,7 @@ efi_gettimeofday (struct timespec *ts)
>  }
>  
>  static int
> -is_available_memory (efi_memory_desc_t *md)
> +is_memory_available (efi_memory_desc_t *md)
>  {
>  	if (!(md->attribute & EFI_MEMORY_WB))
>  		return 0;
> @@ -892,7 +892,7 @@ find_memmap_space (void)
>  			}
>  			contig_high = GRANULEROUNDDOWN(contig_high);
>  		}
> -		if (!is_available_memory(md) || md->type = EFI_LOADER_DATA)
> +		if (!is_memory_available(md) || md->type = EFI_LOADER_DATA)
>  			continue;
>  
>  		/* Round ends inward to granule boundaries */
> @@ -968,7 +968,7 @@ efi_memmap_init(unsigned long *s, unsign
>  			}
>  			contig_high = GRANULEROUNDDOWN(contig_high);
>  		}
> -		if (!is_available_memory(md))
> +		if (!is_memory_available(md))
>  			continue;
>  
>  		/*

Makes sense, I guess.  However the "clash" is, afaict, only due to the fact
that ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.19-rc6/2.6.19-rc6-mm2/broken-out/x86_64-mm-i386-efi-memmap.patch
makes is_memory_available() non-static and declares it in linux/efi.h.

Does ia64 need similar functionality to that which is provided in
x86_64-mm-i386-efi-memmap.patch?

If so, a suitable fix would be to remove the `static' from ia64's
definition of is_memory_available() and then wire it up in the appropriate
place elsewhere under arch/ia64.


