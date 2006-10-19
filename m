From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 19 Oct 2006 16:41:19 +0000
Subject: Re: [RFC] virtual memmap for sparsemem [2/2] for ia64.
Message-Id: <Pine.LNX.4.64.0610190940140.8072@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061019172328.4bcb1551.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061019172328.4bcb1551.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Oct 2006, KAMEZAWA Hiroyuki wrote:

> +config ARCH_VMEMMAP_SPARSEMEM_SUPPORT
> +	def_bool y
> +	depends on PGTABLE_4 && ARCH_SPARSEMEM_ENABLE

Why do you need to depend on 4 level page tables?

> +#if defined(CONFIG_VIRTUAL_MEM_MAP) || defined(CONFIG_VMEMMAP_SPARSEMEM)
>  unsigned long vmalloc_end = VMALLOC_END_INIT;

I'd rather stop tinkering around with vmalloc_end. See my patches that I 
posted last week to realize virtual memmap.
