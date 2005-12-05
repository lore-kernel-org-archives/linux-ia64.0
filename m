From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 05 Dec 2005 16:11:01 +0000
Subject: Re: [PATCH] ACPI EC driver on ia64
Message-Id: <200512050911.01808.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <43941A47.40304@jp.fujitsu.com>
In-Reply-To: <43941A47.40304-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

On Monday 05 December 2005 3:45 am, Kenji Kaneshige wrote:
> I need an ACPI EC driver on my IA64 machine. Currently CONFIG_ACPI_EC
> depends on X86, so I cannot build ACPI EC driver on ia64. I tested
> ACPI EC driver on ia64 with my special Kconfig, and it seemed to work
> well. Could you consider applying the following patch to enable ACPI
> EC driver on ia64?

>  config ACPI_EC
>  	bool
> -	depends on X86
> +	depends on IA64 || X86

Why not just remove the "depends on" altogether?  I don't see anything
in ec.c that's architecture-dependent.
