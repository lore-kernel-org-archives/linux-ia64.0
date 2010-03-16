From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Tue, 16 Mar 2010 01:54:40 +0000
Subject: Re: [PATCH v4 04/11] swiotlb: support NOT_COHERENT_CACHE PowerPC
Message-Id: <20100316105423B.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1268421166-4791-1-git-send-email-albert_herranz@yahoo.es>
	<1268421166-4791-5-git-send-email-albert_herranz@yahoo.es>
In-Reply-To: <1268421166-4791-5-git-send-email-albert_herranz@yahoo.es>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: albert_herranz@yahoo.es
Cc: linux-usb@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org

On Fri, 12 Mar 2010 20:12:39 +0100
Albert Herranz <albert_herranz@yahoo.es> wrote:

> The current SWIOTLB code does not support NOT_COHERENT_CACHE platforms.
> This patch adds support for NOT_COHERENT_CACHE platforms to SWIOTLB by
> adding two platform specific functions swiotlb_dma_sync_page() and
> swiotlb_dma_sync() which can be used to explicitly manage cache coherency.
> 
> On PowerPC these functions are mapped to their corresponding
> __dma_sync_page() and __dma_sync() functions.
> On other architectures using SWIOTLB these functions are optimized out.
> 
> This will be used later to support SWIOTLB on the Nintendo Wii video game
> console.
> 
> CC: linuxppc-dev@lists.ozlabs.org
> CC: linux-kernel@vger.kernel.org
> CC: x86@kernel.org
> CC: linux-ia64@vger.kernel.org
> Signed-off-by: Albert Herranz <albert_herranz@yahoo.es>
> ---
>  arch/ia64/include/asm/swiotlb.h    |   10 ++++++++++
>  arch/powerpc/include/asm/swiotlb.h |    3 +++
>  arch/x86/include/asm/swiotlb.h     |   10 ++++++++++
>  lib/swiotlb.c                      |   30 ++++++++++++++++++++++++------
>  4 files changed, 47 insertions(+), 6 deletions(-)

Why can't you use dma_sync_single_* instead of inventing new
swiotlb sync functions?
