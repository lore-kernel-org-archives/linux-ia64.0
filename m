From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 19 Dec 2003 23:10:11 +0000
Subject: Re: [PATCH] - linux/arch/ia64/kernel/acpi.c
Message-Id: <marc-linux-ia64-107187556022118@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107177513519511@msgid-missing>
In-Reply-To: <marc-linux-ia64-107177513519511@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 18 Dec 2003 13:14:42 -0600, Jack Steiner <steiner@sgi.com> said:

  Jack> The code in acpi_numa_memory_affinity_init that sorts the
  Jack> node_memblk can overrun the array & clobber the memory that
  Jack> follows the end of the array. The error will be seen only on
  Jack> systems that fill the node_memblk array and only if SAL doesnt
  Jack> sort the entries in the SRAT.


> --- linux.base/arch/ia64/kernel/acpi.c	Wed Nov 26 14:44:07 2003
> +++ linux/arch/ia64/kernel/acpi.c	Thu Dec 18 13:10:03 2003
> @@ -413,7 +413,7 @@
>  			break;
>  	}
>  	if (p < pend) {
> -		for (q = pend; q >= p; q--)
> +		for (q = pend - 1; q >= p; q--)
>  			*(q + 1) = *q;
>  	}
>  	p->start_paddr = paddr;

Looks correct to me.  Applied.

	--david
