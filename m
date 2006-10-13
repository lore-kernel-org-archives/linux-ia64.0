From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 13 Oct 2006 00:56:40 +0000
Subject: Re: [PATCH 4/4] vmm: Use a static memory map
Message-Id: <20061013095640.c181bb9c.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 12 Oct 2006 12:18:28 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> - The plan is to further generalize the virtual mem map support
>   in the Linux kernel. With this patch the virtual memory map
>   is more independent from VMALLOC.
This purpose is great. I like this patch.

> +#define VIRTUAL_MEM_MAP_SIZE   (1UL << (IA64_MAX_PHYS_BITS - PAGE_SHIFT +\
> +					STRUCT_PAGE_ORDER))

I'm not sure but Is this size of virtual-memory able to be mapped by any configs ?


>  #else
> -# define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
> +#define VIRTUAL_MEM_MAP_SIZE 0
>  #endif
>  
> +#define VMALLOC_START  (VIRTUAL_MEM_MAP + VIRTUAL_MEM_MAP_SIZE)
> +#define VMALLOC_END    (RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
> +
And, (1UL << (4*PAGE_SHIFT-9)) - VIRTUAL_MEM_MAP_SIZE is real VMALLOC size. 
I think.

-Kame


