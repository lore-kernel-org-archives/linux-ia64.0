From: "Nguyen, Tom L" <tom.l.nguyen@intel.com>
Date: Tue, 13 Apr 2004 21:54:05 +0000
Subject: RE: [PATCH] PCI MSI Kconfig consolidation
Message-Id: <C7AB9DA4D0B1F344BF2489FA165E502404058238@orsmsx404.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404131041.06275.bjorn.helgaas@hp.com>
In-Reply-To: <200404131041.06275.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andi Kleen <ak@suse.de>

On Tuesday, April 13, Bjorn Helgaas wrote:

> No.  This is one reason why I think the MSI configuration symbol
> should be CONFIG_PCI_MSI, not CONFIG_PCI_USE_VECTOR.

Agree. The MSI configuration symbol should be CONFIG_PCI_MSI. We will update it, including
your PCI MSI Kconfig consilidation patch.

Thanks,
Long

