From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 16 Jul 2009 03:40:18 +0000
Subject: Re: [PATCH 04/15] swiotlb: remove unnecessary swiotlb_bus_to_virt
Message-Id: <1247715618.27937.36.camel@pasglop>
List-Id: <linux-ia64.vger.kernel.org>
References: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
	 <1247187904-31999-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
	 <5E909C02-3FA2-4BEB-8C73-F4E4A5A404BF@kernel.crashing.org>
In-Reply-To: <5E909C02-3FA2-4BEB-8C73-F4E4A5A404BF@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Becky Bruce <beckyb@kernel.crashing.org>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, tony.luck@intel.com, x86@kernel.org

On Mon, 2009-07-13 at 21:17 -0500, Becky Bruce wrote:
> 
> phys_to_virt (also, virt_to_phys) is invalid for highmem addresses on  
> ppc. 

I would be surprised if x86 was any different here. Most of our highmem
implementation comes straight from x86 :-)

Cheers,
Ben.


