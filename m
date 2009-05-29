From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Fri, 29 May 2009 21:09:16 +0000
Subject: Re: [PATCH 6/9] swiotlb: use dma_to_phys and phys_to_dma
Message-Id: <4A204EFC.501@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1243586643-5554-1-git-send-email-ian.campbell@citrix.com> <1243586643-5554-7-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1243586643-5554-7-git-send-email-ian.campbell@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ian Campbell <ian.campbell@citrix.com>
Cc: linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Olaf Kirch <okir@suse.de>, Greg KH <gregkh@suse.de>, Tony Luck <tony.luck@intel.com>, Becky Bruce <beckyb@kernel.crashing.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kumar Gala <galak@kernel.crashing.org>, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org

Ian Campbell wrote:
> static dma_addr_t swiotlb_virt_to_bus(struct device *hwdev,
>  				      volatile void *address)
>  {
> -	return swiotlb_phys_to_bus(hwdev, virt_to_phys(address));
> +	return phys_to_dma(hwdev, virt_to_phys(address));
>  }
>  
>  void * __weak swiotlb_bus_to_virt(struct device *hwdev, dma_addr_t address)
>   

Does this need to be weak too?

    J
