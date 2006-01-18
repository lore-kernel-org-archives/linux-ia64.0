From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 18 Jan 2006 17:29:46 +0000
Subject: Re: [PATCH 2.6.15] ia64: use i386 dmi_scan.c
Message-Id: <200601181029.46352.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <200601131724.42054.bjorn.helgaas@hp.com> <200601171717.03192.bjorn.helgaas@hp.com>
In-Reply-To: <200601171717.03192.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Domsch <Matt_Domsch@dell.com>
Cc: linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-kernel@vger.kernel.org

On Tuesday 17 January 2006 17:17, Bjorn Helgaas wrote:
>> But it's a start, and maybe the consolidation could be done later.
> 
> Index: work-mm3/arch/i386/kernel/dmi_scan.c
> =================================> --- work-mm3.orig/arch/i386/kernel/dmi_scan.c	2006-01-17 15:18:42.000000000 -0700
> +++ work-mm3/arch/i386/kernel/dmi_scan.c	2006-01-17 16:58:11.000000000 -0700
> @@ -39,9 +39,18 @@
>  			    void (*decode)(struct dmi_header *))
>  {
>  	u8 *buf, *data;
> -	int i = 0;
> +	int iomem = 1, i = 0;
>  		
> -	buf = dmi_ioremap(base, len);
> +	if (efi_enabled) {
> +		if (efi_mem_attributes(base & EFI_MEMORY_WB)) {

Ouch, ignore this patch if you haven't already.  The above is
parenthesized wrong.

Matt, what's your opinion on proceeding?  I know you want to get
the DMI stuff in distros.  I'm looking at reworking ioremap to
hide all this stuff, but that'll be a bigger change and may be
harder to get into distro releases.

For upstream, the ioremap rework sounds like the way to go, but
I don't know which the distros would prefer for updates.
