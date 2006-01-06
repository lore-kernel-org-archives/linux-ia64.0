From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Fri, 06 Jan 2006 19:03:17 +0000
Subject: RE: [PATCH 2.6.15] ia64: use i386 dmi_scan.c
Message-Id: <D36CE1FCEFD3524B81CA12C6FE5BCAB00C081899@fmsmsx406.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060106172140.GB19605@lists.us.dell.com>
In-Reply-To: <20060106172140.GB19605@lists.us.dell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Domsch <Matt_Domsch@Dell.com>, linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org
Cc: linux-kernel@vger.kernel.org

Matt Domsch <> wrote:
> Enable DMI table parsing on ia64.
...
> +#ifndef CONFIG_EFI
> +void __init dmi_scan_machine(void)
> +{
>  	char __iomem *p, *q;
> +	int rc;

Hi Matt,

You could potentially consolidate the two dmi_scan_machine functions
and lose the ifdef (and duplication) by checking efi_enabled instead.  
'efi_enabled' is already ifdef'd in the EFI header (defined to 1 for 
ia64) specifically for this situation.  

matt
