From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 30 Apr 2004 18:04:44 +0000
Subject: RE: SAL PCI config space
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F011E7003@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>ia64_sal_pci_config_read() and ia64_sal_pci_config_write() use 
>SAL_CALL(). This takes an IRQ-safe spinlock, but SAL 3.2 says that 
>SAL_PCI_CONFIG_READ and SAL_PCI_CONFIG_WRITE are both MP-safe and
>reentrant.  So is there any reason we shouldn't use SAL_CALL_REENTRANT?

Theoretically there might be older SAL implementations where these
aren't re-entrant ... so to be really safe, you'd have to check that
the SAL version is >= 3.2 before using the SAL_CALL_REENTRANT form.

-Tony
