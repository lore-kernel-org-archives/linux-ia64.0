From: "Leonardo Chiquitto" <lchiquitto@novell.com>
Date: Wed, 21 Oct 2009 13:29:17 +0000
Subject: Re: [PATCH] ia64: fix SBA IOMMU to handle allocation failure
Message-Id: <4ADEF08D020000860004410B@sinclair.provo.novell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091018140631K.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20091018140631K.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

> This is an updated patch of the patch that I've posted one year
> ago. Shehjar reported the problem and confirmed that the patch fixes
> it:
> 
> http://lkml.indiana.edu/hypermail/linux/kernel/0811.0/01562.html
> 
> Leonardo told me that he hit the same problem and confirmed that the
> patch fixes it.
> 
> > From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Subject: [PATCH] ia64: fix SBA IOMMU to handle allocation failure properly
> 
> It's possible that SBA IOMMU might fail to find I/O space under heavy
> I/Os. SBA IOMMU panics on allocation failure but it shouldn't; drivers
> can handle the failure. The majority of other IOMMU drivers don't
> panic on allocation failure.
> 
> This patch fixes SBA IOMMU path to handle allocation failure properly.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Thanks for refreshing and resubmitting this. I just received feedback
confirming that the patch resolves the problem.

Kind regards,
Leonardo

