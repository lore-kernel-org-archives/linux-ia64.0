From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 23 May 2003 18:39:25 +0000
Subject: Re: [Linux-ia64] [PATCH] 2.5 - Change mmu_gathers into per-cpu data
Message-Id: <marc-linux-ia64-105590723706010@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706004@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706004@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 23, 2003 at 01:52:46PM -0400, Martin Hicks wrote:
> 
> Hello,
> 
> Here is a patch to move the mmu_gathers struct into the per-cpu data
> region.
> 
> The patch is against the linux-ia64-2.5 tree.

Could you also submit such a patch for asm-generic/tlb.h and the other arches?


