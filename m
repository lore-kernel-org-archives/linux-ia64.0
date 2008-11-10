From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 10 Nov 2008 12:59:57 +0000
Subject: Re: [Q] Why does dma_alloc_coherent() of ia64 GFP_DMA?
Message-Id: <87d4h3pwhe.fsf@basil.nowhere.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com>
In-Reply-To: <20081110121123.F82A.E1E9C6FF@jp.fujitsu.com> (Yasunori Goto's message of "Mon, 10 Nov 2008 13:47:51 +0900")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, Joerg Roedel <joerg.roedel@amd.com>

Yasunori Goto <y-goto@jp.fujitsu.com> writes:
>
> However, I think this has the possibility of a finishing blow of OOM.
> For example,
>
>   1) Page caches occupy normal zone, and DMA zone is free.
>   2) A user's application requires a few GB memory and mlock it.
>      All DMA zone is occupied by it.

The VM has special "lower zone protection" to protect against these
kinds of deadlocks. They can be circumvented, but it takes effort.

>   3) A device which allows over 4GB is hot-added.
>      But dma_alloc_coherent() try to allocate DMA zone.
>      Then OOM occurs because there is no freeable pages.
>
> I heard there are some users who require a few GB mlock.

Normally mlock is limited to half the memory exactly to avoid
such problems.

Also I believe there are some issues with non continuous memory on
some IA64 systems -- e.g. Altixes iirc have the requirement
that you use the IOMMU for higher memory. So it's probably
not easy to change.

-Andi

-- 
ak@linux.intel.com
