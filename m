From: "Nguyen, Tom L" <tom.l.nguyen@intel.com>
Date: Tue, 13 Apr 2004 21:57:18 +0000
Subject: RE: [PATCH] PCI MSI Kconfig consolidation
Message-Id: <C7AB9DA4D0B1F344BF2489FA165E502404058239@orsmsx404.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404131041.06275.bjorn.helgaas@hp.com>
In-Reply-To: <200404131041.06275.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>, Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tuesday, April 13, 2004 Andi Kleen wrote:

>> 
>> In fact, I think there's a whole lot more architecture-specific
>> knowledge that has leaked across into drivers/pci/msi.[ch].  For
>
>Yes. Far too lot. Even for the relatively small x86<->x86-64 differences.
>That was the reason I disabled it for x86-64 initially ....
>[hoping that someone with MSI hardware will fix and reenable it]

We are in the progress of enabling MSI on x86_64.

Thanks,
Long
