From: Matthew Wilcox <willy@debian.org>
Date: Fri, 27 Feb 2004 19:24:59 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <20040227192459.GP25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 27, 2004 at 10:52:46AM -0800, David Mosberger wrote:
> The patch also changes the arguments for ia64_sal_pci_config_read()
> and ia64_sal_pci_config_write(), without changing any callers.
> Why?

Because I made a mistake; I intended to delete that part from that patch.
It's part of the [3/4] patch I sent you earlier today.

> Also, how about putting a colon after "SAL Platform features"?

Sure.  While we're nitpicking, how about deleting the 'oem=' and `product='
from the printk?  It currently looks like:

SAL 3.1: oem=HP, product=, version 2.21

How about instead it reading

SAL 3.1: HP  version 2.21

(if we filled in the product field, it'd read something like
SAL 3.1: HP rx2600 version 2.21
)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
