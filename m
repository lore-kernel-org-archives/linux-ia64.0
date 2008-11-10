From: Robin Holt <holt@sgi.com>
Date: Mon, 10 Nov 2008 19:07:11 +0000
Subject: Re: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <20081110190711.GG8483@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com> <87d4h3pwhe.fsf@basil.nowhere.org>
In-Reply-To: <87d4h3pwhe.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <andi@firstfloor.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, "Luck, Tony" <tony.luck@intel.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, Joerg Roedel <joerg.roedel@amd.com>

On Mon, Nov 10, 2008 at 01:59:57PM +0100, Andi Kleen wrote:
> Yasunori Goto <y-goto@jp.fujitsu.com> writes:

> >   3) A device which allows over 4GB is hot-added.
> >      But dma_alloc_coherent() try to allocate DMA zone.
> >      Then OOM occurs because there is no freeable pages.
> >
> > I heard there are some users who require a few GB mlock.
> 
> Normally mlock is limited to half the memory exactly to avoid
> such problems.
> 
> Also I believe there are some issues with non continuous memory on
> some IA64 systems -- e.g. Altixes iirc have the requirement
> that you use the IOMMU for higher memory. So it's probably
> not easy to change.

I am not sure what is be referred to here, but all of an Altix's memory is
DMA capable with the exception of the stuff covered by the MSPEC driver
(that is uncached memory).  There are certainly all sort of special
requirements for doing transfers on Altix to eliminate memory ordering
problems, but nothing specific that I recall related to address ranges
and DMA.

I appologize in advance if I am answering a different question that
was asked.

Thanks,
Robin
