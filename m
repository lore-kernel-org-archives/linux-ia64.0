From: Joerg Roedel <joerg.roedel@amd.com>
Date: Mon, 08 Sep 2008 12:00:17 +0000
Subject: Re: [PATCH 0/5] fix exhaustion of ZONE_DMA with swiotlb (in x86 tree)
Message-Id: <20080908120017.GI3189@amd.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220865014-1169-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1220865014-1169-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org

On Mon, Sep 08, 2008 at 06:10:09PM +0900, FUJITA Tomonori wrote:
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

Cool :-)

This is much better than our last two tries to solve this problem. Doing
no gfp handling at all in swiotlb_alloc_coherent is a nice and clean
solution.

Joerg

-- 
           |           AMD Saxony Limited Liability Company & Co. KG
 Operating |         Wilschdorfer Landstr. 101, 01109 Dresden, Germany
 System    |                  Register Court Dresden: HRA 4896
 Research  |              General Partner authorized to represent:
 Center    |             AMD Saxony LLC (Wilmington, Delaware, US)
           | General Manager of AMD Saxony LLC: Dr. Hans-R. Deppe, Thomas McCoy

