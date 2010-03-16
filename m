From: Albert Herranz <albert_herranz@yahoo.es>
Date: Tue, 16 Mar 2010 06:17:46 +0000
Subject: Re: [PATCH v4 04/11] swiotlb: support NOT_COHERENT_CACHE PowerPC
Message-Id: <4B9F228A.8030005@yahoo.es>
List-Id: <linux-ia64.vger.kernel.org>
References: <1268421166-4791-1-git-send-email-albert_herranz@yahoo.es>	<1268421166-4791-5-git-send-email-albert_herranz@yahoo.es>	<20100316105423B.fujita.tomonori@lab.ntt.co.jp> <20100316112444D.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20100316112444D.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux-usb@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org

FUJITA Tomonori wrote:
> If we want to make swiotlb generic (make on any architectures), we
> need to handle more cache issues here, I think. So it's better to have
> more generic ways instead of adding hooks to some archs.
> 

Ok. So what would be an acceptable way of handling this in a generic way?
Should we for example have 2 levels of DMA ops in the swiotlb case (swiotlb and "actual") and call the 2nd level ("actual") from the swiotlb code whenever we need to act on non-bounced buffers?
Any other ideas?

Thanks,
Albert

