From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Mon, 27 Sep 2004 20:06:16 +0000
Subject: Re: [PATCH][3/4] Add hotplug support to drivers/acpi/numa.c
Message-Id: <20040927130616.B30443@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <20040920094719.H14208@unix-os.sc.intel.com> <20040924012301.000007c6.tokunaga.keiich@jp.fujitsu.com> <20040924013255.00000337.tokunaga.keiich@jp.fujitsu.com>
In-Reply-To: <20040924013255.00000337.tokunaga.keiich@jp.fujitsu.com>; from tokunaga.keiich@jp.fujitsu.com on Fri, Sep 24, 2004 at 01:32:55AM +0900
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Cc: anil.s.keshavamurthy@intel.com, len.brown@intel.com, acpi-devel@lists.sourceforge.net, lhns-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Sep 24, 2004 at 01:32:55AM +0900, Keiichiro Tokunaga wrote:
> +void acpi_numa_node_init(acpi_handle handle)
Why is this function returning void? I expect
this to return int, what do you think?
> +
> +	if (acpi_bus_get_device(handle, &node_dev)) {
> +		printk(KERN_ERR"Unknown handle.\n");
> +		return_VOID;
> +	}
Why do you need to call acpi_bus_get_device?

> +	acpi_walk_namespace(ACPI_TYPE_PROCESSOR,
> +			    handle,
> +			    (u32) 1,
> +			    find_processor,
> +			    data,
> +			    (void **)&cnt);
Why are you looking for processor device here?
Please remove this acpi_walk_namespace function.

> +	/*
> diff -puN /dev/null include/acpi/numa.h
> +#ifndef MAX_PXM_DOMAINS
> +#define MAX_PXM_DOMAINS (256)
> +#endif
Why defining it again, It is already defined in asm-ia64/acpi.h file
> 
> _
