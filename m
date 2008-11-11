From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Tue, 11 Nov 2008 05:48:11 +0000
Subject: Re: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <20081111144711B.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com>
	<87d4h3pwhe.fsf@basil.nowhere.org>
In-Reply-To: <87d4h3pwhe.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: andi@firstfloor.org
Cc: y-goto@jp.fujitsu.com, tony.luck@intel.com, fujita.tomonori@lab.ntt.co.jp, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, joerg.roedel@amd.com

On Mon, 10 Nov 2008 13:59:57 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> Also I believe there are some issues with non continuous memory on
> some IA64 systems -- e.g. Altixes iirc have the requirement
> that you use the IOMMU for higher memory. So it's probably
> not easy to change.

Are you talking about this odd dma requirement?

http://www.gelato.unsw.edu.au/archives/linux-ia64/0305/5604.html
