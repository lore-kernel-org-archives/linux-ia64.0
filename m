From: Matt Domsch <Matt_Domsch@dell.com>
Date: Fri, 06 Jan 2006 22:36:52 +0000
Subject: Re: [PATCH 2.6.15] ia64: use i386 dmi_scan.c
Message-Id: <20060106223652.GA9230@lists.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <D36CE1FCEFD3524B81CA12C6FE5BCAB00C081899@fmsmsx406.amr.corp.intel.com>
In-Reply-To: <D36CE1FCEFD3524B81CA12C6FE5BCAB00C081899@fmsmsx406.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Cc: linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, linux-kernel@vger.kernel.org

On Fri, Jan 06, 2006 at 11:03:17AM -0800, Tolentino, Matthew E wrote:
> Matt Domsch <> wrote:
> > Enable DMI table parsing on ia64.
> ...
> > +#ifndef CONFIG_EFI
> > +void __init dmi_scan_machine(void)
> > +{
> >  	char __iomem *p, *q;
> > +	int rc;
> 
> Hi Matt,
> 
> You could potentially consolidate the two dmi_scan_machine functions
> and lose the ifdef (and duplication) by checking efi_enabled instead.  
> 'efi_enabled' is already ifdef'd in the EFI header (defined to 1 for 
> ia64) specifically for this situation.  

Good idea, patch to follow.

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
