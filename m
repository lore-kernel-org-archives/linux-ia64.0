From: Vinod Koul <vkoul@kernel.org>
Date: Tue, 27 Nov 2018 13:58:37 +0000
Subject: Re: [PATCH V2] mm: Replace all open encodings for NUMA_NO_NODE
Message-Id: <20181127135809.GB3175@vkoul-mobl.Dlink>
List-Id: <linux-ia64.vger.kernel.org>
References: <1543235202-9075-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1543235202-9075-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, akpm@linux-foundation.org, jiangqi903@gmail.com, hverkuil@xs4all.nl

On 26-11-18, 17:56, Anshuman Khandual wrote:
> At present there are multiple places where invalid node number is encoded
> as -1. Even though implicitly understood it is always better to have macros
> in there. Replace these open encodings for an invalid node number with the
> global macro NUMA_NO_NODE. This helps remove NUMA related assumptions like
> 'invalid node' from various places redirecting them to a common definition.
> 

>  drivers/dma/dmaengine.c                       |  4 +++-


Acked-by: Vinod Koul <vkoul@kernel.org>

-- 
~Vinod
