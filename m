From: "Kenneth Chen" <kenneth.w.chen@intel.com>
Date: Fri, 19 Mar 2004 01:07:05 +0000
Subject: Re: [PATCH] ia64/Kconfig
Message-Id: <200403190107.i2J175F14029@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403151717.39545.bjorn.helgaas@hp.com>
In-Reply-To: <200403151717.39545.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This Kconfig patch basically just makes ia64 look a little more like i386:
> 	- moves system type above processor type
> 	- moves PM & ACPI to a new top-level menu
> 	- moves PCI/PCMCIA to a new top-level menu
>
> @@ -97,6 +79,24 @@
>  endchoice
>
>  choice
> +	prompt "Processor type"
> +	default ITANIUM
> +


Anyone still running itanium processor nowadays? :-)


