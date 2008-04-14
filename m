From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 14 Apr 2008 16:09:34 +0000
Subject: RE: [PATCH] NUMA memory configuration issue
Message-Id: <1FE6DD409037234FAB833C420AA843EC010D61DC@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47FE313B.2010600@bull.net>
In-Reply-To: <47FE313B.2010600@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Do you think contig.c is also effected?
> Can you please explain why?

No action is required in the contig.c case, but the compiler grumbles
because you changed the type (of the arguments) for register_active_ranges().
So for a .config with CONFIG_VIRTUAL_MEM_MAP=y the following warning is
produced:

  CC      arch/ia64/mm/contig.o
arch/ia64/mm/contig.c: In function `paging_init':
arch/ia64/mm/contig.c:258: warning: passing arg 1 of `efi_memmap_walk' from incompatible pointer type

-Tony
