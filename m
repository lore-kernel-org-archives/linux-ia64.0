From: Grant Grundler <iod00d@hp.com>
Date: Tue, 13 Apr 2004 20:09:08 +0000
Subject: Re: [PATCH] PCI MSI Kconfig consolidation
Message-Id: <20040413200908.GF6559@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <C7AB9DA4D0B1F344BF2489FA165E502404058232@orsmsx404.jf.intel.com>
In-Reply-To: <C7AB9DA4D0B1F344BF2489FA165E502404058232@orsmsx404.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Nguyen, Tom L" <tom.l.nguyen@intel.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andi Kleen <ak@suse.de>

On Tue, Apr 13, 2004 at 12:16:10PM -0700, Nguyen, Tom L wrote:
> It looks good; however, it may create a confusion on ia64 because ia64 
> is already vector-based indexing. 

Ok. Can you submit another patch to cleanup the wording so it's clear
this option only changes ia32 IRQ support?

The key feature is MSI support (which I think depends on vector-based
indexing) which is arch independent.

grant
