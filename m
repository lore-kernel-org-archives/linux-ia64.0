From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 Oct 2004 20:34:53 +0000
Subject: RE: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0221C989@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>
In-Reply-To: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Gefre <pfg@sgi.com>
Cc: cngam@sgi.com, Matthew Wilcox <matthew@wil.cx>, Grant Grundler <iod00d@hp.com>, Jesse Barnes <jbarnes@engr.sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>It had been suggested that we submit this as new code - since 
>it can't be transitioned to. And I thought that was what we
>had decided on - a 'kill' patch and an 'add' patch.

Sorry ... I must have missed that.

>I can remove any Lindent'ing of older files if you don't want that.

Yes please.

>I will take out the Kconfig mod.

Good.

>I believe Christoph is the maintainer of the qla driver (he was one of 
>the reviewers).

His fingerprints are all over the revision history.  It looks like the
only real change you want here is deleting the ugly hack for SN2:

< #if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_SGI_SN2)
< #include <asm/sn/pci/pciio.h>
< /* Ugly hack needed for the virtual channel fix on SN2 */
< extern int snia_pcibr_rrb_alloc(struct pci_dev *pci_dev,
< 				int *count_vchan0, int *count_vchan1);
< #endif

If Christoph signs off on that, then I can feed a separate patch
that does that at the same time as the kill/add.

-Tony


