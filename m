From: Philippe =?iso-8859-1?Q?Gramoull=E9?= <philippe.gramoulle@mmania.com>
Date: Fri, 16 Nov 2001 10:24:12 +0000
Subject: Re: [Linux-ia64] PATCH: Fix for 4KB kernel corruption
Message-Id: <marc-linux-ia64-105590698805527@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805523@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805523@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Siddha,

Can this corruption happen with on lion with 4Go of memory also ?

Thanks,

Philippe.

"Siddha, Suresh B" wrote:
> 
> Hi,
> 
> 4KB page size kernel is broken on Lion with 8GB memory. ia64_boot_param
> structure was getting corrupted. Appended patch fixes this problem.
> 
> PAGE_ALIGN is required because: rsvd_region[i].end need not be page aligned
> and in the next iteration of the for loop this can potentially become
> bootmap_start. This can lead to corruption of rsvd_region[i] as
> init_bootmem() takes the pfn of bootmap_start and initialises the bootmem.
> 
> Thanks,
> Suresh
> 
> diff -u linux-2.4.14/arch/ia64/kernel/setup.c~
> linux-2.4.14/arch/ia64/kernel/setup.c
> --- linux-2.4.14/arch/ia64/kernel/setup.c~      Thu Nov 15 16:27:23 2001
> +++ linux-2.4.14/arch/ia64/kernel/setup.c       Thu Nov 15 16:28:01 2001
> @@ -175,7 +175,7 @@
>                 /* nothing more available in this segment */
>                 if (range_end = end) return 0;
> 
> -               free_start = rsvd_region[i].end;
> +               free_start = PAGE_ALIGN(rsvd_region[i].end);
>         }
>         return 0;
>  }
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

