From: Colin Ngam <cngam@sgi.com>
Date: Thu, 14 Oct 2004 22:37:51 +0000
Subject: Re: [PATCH] Introduce PCI <-> CPU address conversion [1/2]
Message-Id: <416EFFBE.7B8F702@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041014124737.GM16153@parcelfarce.linux.theplanet.co.uk> <20041014125348.GA9633@infradead.org> <20041014135323.GO16153@parcelfarce.linux.theplanet.co.uk> <20041014180005.GA11954@infradead.org> <20041014180748.GS16153@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Christoph Hellwig <hch@infradead.org>, Greg KH <greg@kroah.com>, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Matthew Wilcox wrote:

> On Thu, Oct 14, 2004 at 07:00:06PM +0100, Christoph Hellwig wrote:
> > For some architectures the sysdata is different for bus vs device, so
> > yes, we do want strict typechecking.
>
> How interesting.  I was under the impression that dev->sysdata was always
> a copy of the bus's.  If that's not guaranteed, then we're just going
> to have to dereference the additional pointer and use the bus' sysdata.

Hi Matthew,

On SGI's Altix system, the sysdata for the device is very much different than
the sysdata for the bus.

Thanks.

colin

>
>
> --
> "Next the statesmen will invent cheap lies, putting the blame upon
> the nation that is attacked, and every man will be glad of those
> conscience-soothing falsities, and will diligently study them, and refuse
> to examine any refutations of them; and thus he will by and by convince
> himself that the war is just, and will thank God for the better sleep
> he enjoys after this process of grotesque self-deception." -- Mark Twain
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

