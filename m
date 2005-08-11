From: Jeff Garzik <jgarzik@pobox.com>
Date: Thu, 11 Aug 2005 22:03:21 +0000
Subject: Re: [PATCH] IDE: don't offer IDE_GENERIC on ia64
Message-Id: <42FBCB29.5040900@pobox.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F041DACC8@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F041DACC8@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, B.Zolnierkiewicz@elka.pw.edu.pl, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>Tony, others, does this change give you any heartburn?  On
>>the 460GX and 870 boxes I have, IDE is a PCI device.
> 
> 
> No heartburn for me ... as you say IDE is built into one
> of the 870 chips.
> 
> I don't know whether any non-Intel chipsets provide legacy IDE.

The question is not about ISA IDE, but more about the PCI IDE 
specification...  See the PCI IDE examples in my other emails.

	Jeff



