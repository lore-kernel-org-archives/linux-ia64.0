From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 01 Mar 2005 21:51:18 +0000
Subject: Re: take7: vector sharing (Large I/O system support)
Message-Id: <20050301215118.GC5167@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42226CCE.6070706@jp.fujitsu.com>
In-Reply-To: <42226CCE.6070706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 01, 2005 at 11:35:11AM -0800, David Mosberger wrote:
> >>>>> On Mon, 28 Feb 2005 14:10:53 +0900, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> said:
> 
>   Kenji> Hi Cristoph,
>   >>> +config NR_RTE_CACHES
>   >>> +	int "Number of RTE cache entries"
>   >>> +	depends on IOSAPIC
>   >>> +	default "256"
>   >>> +	help
>   >>> +	  If your system panic with the message "out of rte cache
>   >>> +	  entries!(shortage: XX)", please set this to a larger value.
>   >> 
>   >> 
>   >> This screams for dynamic allocation of the underlying structures, no?
> 
>   Kenji> Some number (NR_RTE_CACHES) of iosapic_rte_info structures are
>   Kenji> statically allocated because this structure might be needed before
>   Kenji> kmalloc is initialized. The panic message mentioned above means we
>   Kenji> run out of these statically allocated structures.
> 
> The problem is naming, I think.  Those aren't "cache entries", they
> are statically preallocated entries.  How about changing the config
> option name to:

Even for early allocations what speaks against alloc_bootmem?

