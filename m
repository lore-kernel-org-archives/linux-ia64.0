From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Wed, 05 Aug 2009 03:04:56 +0000
Subject: RE: [PATCH] Bug Fix arch/ia64/kernel/pci-dma.c: fix recursive
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8B3821A49@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090804223526.GA26801@linux-os.sc.intel.com>
In-Reply-To: <20090804223526.GA26801@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>On Tue, 4 Aug 2009 15:35:26 -0700
>Fenghua Yu <fenghua.yu@intel.com> wrote:
>
>> In commit dfb805e831cc5306b14eacd64e0b36d0d973ee0d,
>> dma_ops->dma_supported = iommu_dma_supported;
>
>Hmm, the dfb805e831cc5306b14eacd64e0b36d0d973ee0d commit touches only
>dma_ops->mapping_error. It doesn't like like that this commit is
>related with the bug.
>
>I guess that I added the bug when I rewrote IA64 dma operations.

My bad. The commit I refer to should be 160c1d8e40866edfeae7d68816b7005d70acf391
which added the statement:
dma_ops->dma_supported = iommu_dma_supported;

I will change to this commit# in comment when push the patch to upstream.

Thanks.

-Fenghua
