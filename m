From: Andi Kleen <ak@suse.de>
Date: Tue, 13 Apr 2004 21:29:37 +0000
Subject: Re: [PATCH] PCI MSI Kconfig consolidation
Message-Id: <20040413232937.7d907a71.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <C7AB9DA4D0B1F344BF2489FA165E502404058232@orsmsx404.jf.intel.com>
	<200404131408.17248.bjorn.helgaas@hp.com>
In-Reply-To: <200404131408.17248.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: tom.l.nguyen@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 13 Apr 2004 14:08:17 -0600
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:


> 
> In fact, I think there's a whole lot more architecture-specific
> knowledge that has leaked across into drivers/pci/msi.[ch].  For

Yes. Far too lot. Even for the relatively small x86<->x86-64 differences.
That was the reason I disabled it for x86-64 initially ....
[hoping that someone with MSI hardware will fix and reenable it]

-Andi
