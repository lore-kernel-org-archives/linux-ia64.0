From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 30 Apr 2004 18:04:27 +0000
Subject: Re: SAL PCI config space
Message-Id: <1083348267.19296.7.camel@debian>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-04-30 at 11:51, Matthew Wilcox wrote:
> ia64_sal_pci_config_read() and ia64_sal_pci_config_write() use SAL_CALL().
> This takes an IRQ-safe spinlock, but SAL 3.2 says that SAL_PCI_CONFIG_READ
> and SAL_PCI_CONFIG_WRITE are both MP-safe and reentrant.  So is there
> any reason we shouldn't use SAL_CALL_REENTRANT?
> 

   I thought there was going to be further clarification on this, but
I'm not sure what SAL rev it would be in.  On HP boxes, we can't preform
multiple config accesses to the same root bus at the same time.  So far,
the SAL_CALL lock has protected us from needing to worry about it.  I'd
suspect other boxes might have similar restrictions.

	Alex

> (at the moment, we're protected by pci_lock so it wouldn't matter,
> but I'm just about to submit a patch to do away with that)

