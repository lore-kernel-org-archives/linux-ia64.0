From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 03 Feb 2005 19:17:30 +0000
Subject: Re: [PATCH] pci_raw_ops should use unsigned args
Message-Id: <20050203191730.GG20386@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107457685.12618.23.camel@eeyore>
In-Reply-To: <1107457685.12618.23.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, greg@kroah.com

On Thu, Feb 03, 2005 at 12:08:05PM -0700, Bjorn Helgaas wrote:
> Convert pci_raw_ops to use unsigned segment (aka domain),
> bus, and devfn.  With the previous code, various ia64 config
> accesses fail due to segment sign-extension problems.
> 
> ia64:
>     - With a signed seg >= 0x8, unwanted sign-extension occurs when
>       "seg << 28" is cast to u64 in PCI_SAL_EXT_ADDRESS()
>     - PCI_SAL_EXT_ADDRESS(): cast to u64 *before* shifting; otherwise
>       "seg << 28" is evaluated as unsigned int (32 bits) and gets
>       truncated when seg > 0xf
>     - pci_sal_read(): validate "value" ptr as other arches do

I'm not happy about that one -- the PCI access.c guarantees the pointer
is non-NULL.  But I'm going to do a sweep to catch all of these, so I'll
just undo it then.

>     - pci_sal_{read,write}(): return -EINVAL rather than SAL error status
> 
>  arch/i386/pci/direct.c     |   12 ++++++----
>  arch/i386/pci/mmconfig.c   |    6 +++--
>  arch/i386/pci/numa.c       |    6 +++--
>  arch/i386/pci/pcbios.c     |    6 +++--
>  arch/ia64/pci/pci.c        |   53 ++++++++++++++++++---------------------------
>  arch/x86_64/pci/mmconfig.c |    8 ++++--
>  include/linux/pci.h        |    6 +++--
>  7 files changed, 51 insertions(+), 46 deletions(-)
> 
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Acked-by: Matthew Wilcox <matthew@wil.cx>

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
