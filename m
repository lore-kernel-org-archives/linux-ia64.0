From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 14 Oct 2004 13:53:23 +0000
Subject: Re: [PATCH] Introduce PCI <-> CPU address conversion [1/2]
Message-Id: <20041014135323.GO16153@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041014124737.GM16153@parcelfarce.linux.theplanet.co.uk> <20041014125348.GA9633@infradead.org>
In-Reply-To: <20041014125348.GA9633@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <matthew@wil.cx>, Greg KH <greg@kroah.com>, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Oct 14, 2004 at 01:53:48PM +0100, Christoph Hellwig wrote:
> I'd rather have this declared in every architectures asm/ header, so it's
> more explicit that it's an per-arch thing.  Also make it a static inline
> so we get typechecking.

I actually don't want typechecking.  Sometimes you have a device and
sometimes you have a bus.  You can get everything you want (sysdata)
from either, so there's no point in doing dev->bus when all you needed
was right there.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
