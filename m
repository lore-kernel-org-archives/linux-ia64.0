From: Muli Ben-Yehuda <muli@il.ibm.com>
Date: Sun, 07 May 2006 08:47:56 +0000
Subject: Re: [PATCH 1/3] swiotlb: SWIOTLB Cleanup.
Message-Id: <20060507084756.GE6015@rhun.haifa.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060504205822.GC14361@us.ibm.com>
In-Reply-To: <20060504205822.GC14361@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jon Mason <jdmason@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, ak@suse.de, tony.luck@intel.com, linux-ia64@vger.kernel.org, mulix@mulix.org

On Thu, May 04, 2006 at 03:58:23PM -0500, Jon Mason wrote:

> SWIOTLB Cleanup.  Mostly a comment and white space clean-up.
> However, some compiler cache optimizations (via the static and
> __read_mostly keywords) were added, and
> swiotlb_init_with_default_size was renamed swiotlb_init (as that
> functional was redundant)
> 
> This patch has been tested individually and cumulatively on x86_64 and
> cross-compile tested on IA64.  Since I have no IA64 hardware, any
> testing on that platform would be appreciated.

Looks good.

> Signed-off-by: Jon Mason <jdmason@us.ibm.com>

Acked-by: Muli Ben-Yehuda <muli@il.ibm.com>

Cheers,
Muli
