From: Colin Ngam <cngam@sgi.com>
Date: Wed, 09 Mar 2005 15:45:18 +0000
Subject: Re: PCI Express
Message-Id: <422F1A0D.CFA59C66@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler wrote:

Hi Grant,

Thanks for the info.

Bottomline - Processor Interrupt Block not implemented on Altix.

Thanks.

colin

> On Tue, Mar 08, 2005 at 05:29:13PM -0800, Jesse Barnes wrote:
> ...
> > An MSI should behave like a processor sending an IPI to itself since its
> > address can be targeted at the processor's interrupt block and set to
> > generate a local interrupt.  Is that right, Tom & Grant?
>
> Yes - that's how I understand it too.
>
> > If this won't work for us, no biggie, we just have to abstract things a
> > little more.  We could make the MSI into a platform specific cookie that
> > we can store a SHub/PIC/TIO address in and other platforms can use to
> > target the processor interrupt block.
>
> Couple more options:
> o add hooks for MSI quirk/fixup for *after* the MSI has been assigned
>   by generic code.
>
> o make sure all MSI only go to "node local" processors. I thought
>   platform code has some control over the CPU EID and data portion of
>   the MSI. But I haven't looked over that in a few monthes.
>
> grant
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

