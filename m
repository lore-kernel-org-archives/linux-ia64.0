From: Christoph Lameter <cl@linux-foundation.org>
Date: Mon, 10 Nov 2008 21:57:40 +0000
Subject: Re: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <Pine.LNX.4.64.0811101555380.32105@quilx.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com> <87d4h3pwhe.fsf@basil.nowhere.org>
 <20081110190711.GG8483@sgi.com>
In-Reply-To: <20081110190711.GG8483@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, "Luck, Tony" <tony.luck@intel.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, Joerg Roedel <joerg.roedel@amd.com>

On Mon, 10 Nov 2008, Robin Holt wrote:

> I am not sure what is be referred to here, but all of an Altix's memory is
> DMA capable with the exception of the stuff covered by the MSPEC driver
> (that is uncached memory).  There are certainly all sort of special
> requirements for doing transfers on Altix to eliminate memory ordering
> problems, but nothing specific that I recall related to address ranges
> and DMA.

But then ZONE_DMA has nothing to do with memory being dmaable or not.
ZONE_DMA is for legacy devices that cannot do DMA to all of memory.
I vaguely remember having stuffed all the memory into ZONE_NORMAL at some
point. ZONE_DMA vanishes for Altix configurations.

