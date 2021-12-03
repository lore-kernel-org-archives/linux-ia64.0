From: Catalin Marinas <catalin.marinas@arm.com>
Date: Fri, 03 Dec 2021 18:54:38 +0000
Subject: Re: [PATCH RFC 1/4] mm: percpu: Generalize percpu related config
Message-Id: <Yapn7veWrVvWpskW@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211121093557.139034-1-wangkefeng.wang@huawei.com>
 <20211121093557.139034-2-wangkefeng.wang@huawei.com>
In-Reply-To: <20211121093557.139034-2-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: dennis@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, gregkh@linuxfoundation.org, cl@linux.com, will@kernel.org, tsbogend@alpha.franken.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, paul.walmsley@sifive.com, palmer@dabbelt.com, aou@eecs.berkeley.edu, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org, x86@kernel.org

On Sun, Nov 21, 2021 at 05:35:54PM +0800, Kefeng Wang wrote:
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index c4207cf9bb17..4ff73299f8a9 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -1135,6 +1135,10 @@ config NUMA
>  	select GENERIC_ARCH_NUMA
>  	select ACPI_NUMA if ACPI
>  	select OF_NUMA
> +	select HAVE_SETUP_PER_CPU_AREA
> +	select NEED_PER_CPU_EMBED_FIRST_CHUNK
> +	select NEED_PER_CPU_PAGE_FIRST_CHUNK
> +	select USE_PERCPU_NUMA_NODE_ID
>  	help
>  	  Enable NUMA (Non-Uniform Memory Access) support.
>  
> @@ -1151,22 +1155,6 @@ config NODES_SHIFT
>  	  Specify the maximum number of NUMA Nodes available on the target
>  	  system.  Increases memory reserved to accommodate various tables.
>  
> -config USE_PERCPU_NUMA_NODE_ID
> -	def_bool y
> -	depends on NUMA
> -
> -config HAVE_SETUP_PER_CPU_AREA
> -	def_bool y
> -	depends on NUMA
> -
> -config NEED_PER_CPU_EMBED_FIRST_CHUNK
> -	def_bool y
> -	depends on NUMA
> -
> -config NEED_PER_CPU_PAGE_FIRST_CHUNK
> -	def_bool y
> -	depends on NUMA
> -
>  source "kernel/Kconfig.hz"
>  
>  config ARCH_SPARSEMEM_ENABLE

For arm64:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
