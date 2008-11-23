From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Sun, 23 Nov 2008 06:10:05 +0000
Subject: RE: [PATCH] IA64: fix VT-d dma_mapping_error
Message-Id: <A6AD88C3F2289247BE726C37303E1EB88EAB5850@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081122215822A.fujita.tomonori@lab.ntt.co.jp>
	<A6AD88C3F2289247BE726C37303E1EB88EAB57E1@orsmsx505.amr.corp.intel.com>
 <20081123014037A.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20081123014037A.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'FUJITA Tomonori' <fujita.tomonori@lab.ntt.co.jp>
Cc: "Luck, Tony" <tony.luck@intel.com>, "'dwmw2@infradead.org'" <dwmw2@infradead.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'mingo@elte.hu'" <mingo@elte.hu>

>Hmm, intel_dma_mapping_error is used to test only the value that
>intel_map_single() returns. If intel_map_single() returns a non-zero
>dma address, it belongs to hwdev's domain. So intel_dma_mapping_error
>can simply return 1 (failure) if the dma_addr is zero.

Then there is no usage of hwdev which is one of two parameters in intel_dma_mapping_error?

Maybe checking dma_addr only is good enough for the function? At least it's fast to check errors.

Thanks.

-Fenghua
