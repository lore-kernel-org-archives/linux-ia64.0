From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 09 Sep 2008 10:41:07 +0000
Subject: Re: [PATCH 0/5] fix exhaustion of ZONE_DMA with swiotlb (in x86
Message-Id: <20080909194107.8bae460c.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220865014-1169-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1220865014-1169-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, joerg.roedel@amd.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org

On Mon,  8 Sep 2008 18:10:09 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> This patchset (against tip/master) fixes the problem that swiotlb
> exhausts ZONE_DMA:
> 
> http://lkml.org/lkml/2008/8/31/16
> 
> The root problem is that swiotlb_alloc_coherent always use ZONE_DMA,
> which is fine for IA64 but not for x86_64.
> 
> This patchset makes the callers set up the gfp flags so that
> swiotlb_alloc_coherent can stop playing with the gfp flags.
> 
> I think that it would be better to remove the allocation code in
> swiotlb_alloc_coherent theoretically (what swiotlb should do is taking
> care of the swiotlb memory. And swiotlb_alloc_coherent is not useful
> since we use it only when we can't allocate memory reachable by the
> device or we are in out of memory). But that code works for both x86
> and IA64 so it's not so bad, I guess.
> 
> #1 is for IA64, #2-4 for x86, and #5 is for swiotlb.
> 

Thanks, works well for me :)

Tested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

