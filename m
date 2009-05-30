From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Sat, 30 May 2009 13:02:58 +0000
Subject: Re: [PATCH 6/9] swiotlb: use dma_to_phys and phys_to_dma
Message-Id: <1243688578.4399.67.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1243586643-5554-1-git-send-email-ian.campbell@citrix.com>
	 <1243586643-5554-7-git-send-email-ian.campbell@citrix.com>
	 <4A204EFC.501@goop.org>
In-Reply-To: <4A204EFC.501@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Olaf Kirch <okir@suse.de>, Greg KH <gregkh@suse.de>, Tony Luck <tony.luck@intel.com>, Becky Bruce <beckyb@kernel.crashing.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kumar Gala <galak@kernel.crashing.org>, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org

On Fri, 2009-05-29 at 14:09 -0700, Jeremy Fitzhardinge wrote:
> Ian Campbell wrote:
> >  void * __weak swiotlb_bus_to_virt(struct device *hwdev, dma_addr_t address)
> >   
> 
> Does this need to be weak too?

It's was wanted by PowerPC to support highmem, that's what patch 8/9
tries to address in an arch-independent way.

Ian.


