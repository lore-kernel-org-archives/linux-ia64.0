From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 28 Feb 2005 03:12:25 +0000
Subject: Re: take7: vector sharing (Large I/O system support)
Message-Id: <20050228031225.GA5203@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42226CCE.6070706@jp.fujitsu.com>
In-Reply-To: <42226CCE.6070706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 28, 2005 at 09:58:54AM +0900, Kenji Kaneshige wrote:
> Hi Tony,
> 
> I had a good discussion about vector sharing patch with
> Ashok Raj (Thank you Ashok!!) and I made change to it based
> on the comments from him.
> 
> Summary of Changes are:
>   - Removed sharable flag from iosapic_itr_info structure
>   - Made NR_RTE_CACHE_ENTRIES configurable
> 
> Attached patch is against 2.6.11-rc5.
> 
> Thanks,
> Kenji Kaneshige
> 
> 
> Current ia64 linux cannot handle greater than 184 interrupt sources
> because of the lack of vectors. The following patch enables ia64 linux
> to handle greater than 184 interrupt sources by allowing the same
> vector number to be shared by multiple IOSAPIC's RTEs. The design of
> this patch is besed on "Intel(R) Itanium(R) Processor Family Interrupt
> Architecture Guide".
> 
> Even if you don't have a large I/O system, you can see the behavior of
> vector sharing by changing IOSAPIC_LAST_DEVICE_VECTOR to fewer value.
> 
> Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
> 
> 
> ---
> 
>  linux-2.6.11-rc5-kanesige/arch/ia64/Kconfig           |    8 
>  linux-2.6.11-rc5-kanesige/arch/ia64/kernel/iosapic.c  |  356 +++++++++++++-----
>  linux-2.6.11-rc5-kanesige/arch/ia64/kernel/irq_ia64.c |   16 
>  linux-2.6.11-rc5-kanesige/include/asm-ia64/hw_irq.h   |    1 
>  4 files changed, 291 insertions(+), 90 deletions(-)
> 
> diff -puN arch/ia64/Kconfig~vector_sharing arch/ia64/Kconfig
> --- linux-2.6.11-rc5/arch/ia64/Kconfig~vector_sharing	2005-02-25 09:08:18.000000000 +0900
> +++ linux-2.6.11-rc5-kanesige/arch/ia64/Kconfig	2005-02-25 09:08:18.000000000 +0900
> @@ -318,6 +318,14 @@ config ACPI_DEALLOCATE_IRQ
>  	depends on IOSAPIC && EXPERIMENTAL
>  	default y
>  
> +config NR_RTE_CACHES
> +	int "Number of RTE cache entries"
> +	depends on IOSAPIC
> +	default "256"
> +	help
> +	  If your system panic with the message "out of rte cache
> +	  entries!(shortage: XX)", please set this to a larger value.

This screams for dynamic allocation of the underlying structures, no?

