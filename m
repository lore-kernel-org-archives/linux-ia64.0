From: Matthew Wilcox <willy@debian.org>
Date: Fri, 30 Apr 2004 17:51:38 +0000
Subject: SAL PCI config space
Message-Id: <20040430175138.GT22558@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


ia64_sal_pci_config_read() and ia64_sal_pci_config_write() use SAL_CALL().
This takes an IRQ-safe spinlock, but SAL 3.2 says that SAL_PCI_CONFIG_READ
and SAL_PCI_CONFIG_WRITE are both MP-safe and reentrant.  So is there
any reason we shouldn't use SAL_CALL_REENTRANT?

(at the moment, we're protected by pci_lock so it wouldn't matter,
but I'm just about to submit a patch to do away with that)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
