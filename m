From: Patrick Gefre <pfg@sgi.com>
Date: Wed, 06 Oct 2004 15:32:23 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <41641007.5020702@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221C989@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0221C989@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: cngam@sgi.com, Matthew Wilcox <matthew@wil.cx>, Grant Grundler <iod00d@hp.com>, Jesse Barnes <jbarnes@engr.sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>It had been suggested that we submit this as new code - since 
>>it can't be transitioned to. And I thought that was what we
>>had decided on - a 'kill' patch and an 'add' patch.
> 
> 
> Sorry ... I must have missed that.
> 
> 
>>I can remove any Lindent'ing of older files if you don't want that.
> 
> 
> Yes please.
> 
> 
>>I will take out the Kconfig mod.
> 
> 
> Good.
> 
> 
>>I believe Christoph is the maintainer of the qla driver (he was one of 
>>the reviewers).
> 
> 
> His fingerprints are all over the revision history.  It looks like the
> only real change you want here is deleting the ugly hack for SN2:
> 
> < #if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_SGI_SN2)
> < #include <asm/sn/pci/pciio.h>
> < /* Ugly hack needed for the virtual channel fix on SN2 */
> < extern int snia_pcibr_rrb_alloc(struct pci_dev *pci_dev,
> < 				int *count_vchan0, int *count_vchan1);
> < #endif
> 
> If Christoph signs off on that, then I can feed a separate patch
> that does that at the same time as the kill/add.
> 
> -Tony
> 


Tony,

I've updated our ftp site with a new patch.

o Took out the Hotplug Kconfig mod (Tony's request)
o removed Lindent changes for non-sn files (Tony's request)
o SN_SAL_IOIF_RRB_ALLOC is gone (Christoph's request)
o added domain arg to the SAL calls that had bus/device (Christoph's request)
o improved pci_dma.c (Christoph's request)
o removed unused SNDRV_SHUB_??? defs (Christoph's request)
o added our own pci_ops (Grant/Matthew's request)

Patches are here:
ftp://oss.sgi.com/projects/sn2/sn2-update/001-kill-files
ftp://oss.sgi.com/projects/sn2/sn2-update/002-add-files

I also put a separate patch for the qla code:
ftp://oss.sgi.com/projects/sn2/sn2-update/003-qla-mod


