From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 17 Oct 2003 12:05:30 +0000
Subject: Re: [2.6 PATCH] Missing exported symbol
Message-Id: <marc-linux-ia64-106639240404575@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106638921002098@msgid-missing>
In-Reply-To: <marc-linux-ia64-106638921002098@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 01:12:07PM +0200, Andreas Schwab wrote:
> +EXPORT_SYMBOL(csum_partial);

ok.

> @@ -61,6 +62,8 @@
>  #include <asm/pgtable.h>
>  EXPORT_SYMBOL(vmalloc_end);
>  EXPORT_SYMBOL(ia64_pfn_valid);
> +EXPORT_SYMBOL(max_low_pfn);
> +EXPORT_SYMBOL(vmem_map);

what needs these?

> +#include <linux/reboot.h>
> +EXPORT_SYMBOL(machine_power_off);
> +EXPORT_SYMBOL(machine_restart);

dito.  If these are needed the export should probably go into
architecture-independent code.

