From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Sat, 22 Nov 2008 16:40:39 +0000
Subject: RE: [PATCH] IA64: fix VT-d dma_mapping_error
Message-Id: <20081123014037A.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081122215822A.fujita.tomonori@lab.ntt.co.jp>
	<A6AD88C3F2289247BE726C37303E1EB88EAB57E1@orsmsx505.amr.corp.intel.com>
In-Reply-To: <A6AD88C3F2289247BE726C37303E1EB88EAB57E1@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: fenghua.yu@intel.com
Cc: fujita.tomonori@lab.ntt.co.jp, tony.luck@intel.com, dwmw2@infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu

On Sat, 22 Nov 2008 08:18:02 -0800
"Yu, Fenghua" <fenghua.yu@intel.com> wrote:

>  
> >+int intel_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr)
> >+{
> >+	return !dma_addr;
> >+}
> 
> The implementation of inte_dma_mapping_error is incomplete.
> 
> Dma_addr is valid only when it belongs to hwdev's domain. This is all about VT-d isolation fundamental.
> 
> +int intel_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr)
> +{
> +        struct pci_dev *pdev = to_pci_dev(hwdev);
> +        struct dmar_domain *domain;
> +        struct iova *iova;
> +
> +        domain = find_domain(pdev);
> +
> +        iova = find_iova(&domain->iovad, IOVA_PFN(dma_addr));
> +        if (!iova)
> +                return -EINVAL;
> +	   return 0;
> +}

Hmm, intel_dma_mapping_error is used to test only the value that
intel_map_single() returns. If intel_map_single() returns a non-zero
dma address, it belongs to hwdev's domain. So intel_dma_mapping_error
can simply return 1 (failure) if the dma_addr is zero.

Do I misunderstand something?
