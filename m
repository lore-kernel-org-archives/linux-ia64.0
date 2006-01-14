From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Sat, 14 Jan 2006 00:45:22 +0000
Subject: Re: [PATCH 2.6.15] ia64: use i386 dmi_scan.c
Message-Id: <1137199522.9161.15.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com>
	 <20060106172140.GB19605@lists.us.dell.com>
	 <20060106223932.GB9230@lists.us.dell.com>
	 <200601131724.42054.bjorn.helgaas@hp.com>
In-Reply-To: <200601131724.42054.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Matt Domsch <Matt_Domsch@dell.com>, linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-kernel@vger.kernel.org

> Ugh.  I really hate this sort of sharing.  Could dmi_scan.c go in
> drivers/firmware/ or something instead?

Not unreasonable. The DMI standard for the tables isn't specifically an
x86 thing but drawn mostly from the management group stuff. The arch
specific stuff is whether you scan for a table or ask the EFIng firmware

