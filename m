From: Helge Deller <deller@gmx.de>
Date: Thu, 12 Jan 2017 20:04:18 +0000
Subject: Re: [RFC PATCH 3/4] arch, mm: remove arch specific show_mem
Message-Id: <2ca95061-4fb3-9f15-1f99-22e3ddd927dc@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170112131659.23058-1-mhocko@kernel.org>
 <20170112131659.23058-4-mhocko@kernel.org>
In-Reply-To: <20170112131659.23058-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org

On 12.01.2017 14:16, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> We have a generic implementation for quite some time already. If there
> is any arch specific information to be printed then we should add a
> callback called from the generic code rather than duplicate the whole
> show_mem. The current code has resulted in the code duplication and
> the output divergence which is both confusing and adds maintainance
> costs. Let's just get rid of this mess.
> 
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
> Cc: Helge Deller <deller@gmx.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Chris Metcalf <cmetcalf@mellanox.com>
> Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-parisc@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/ia64/mm/init.c      | 48 -----------------------------------------------
>  arch/parisc/mm/init.c    | 49 ------------------------------------------------
>  arch/sparc/mm/init_32.c  | 11 -----------
>  arch/tile/mm/pgtable.c   | 45 --------------------------------------------
>  arch/unicore32/mm/init.c | 44 -------------------------------------------
>  5 files changed, 197 deletions(-)

Thanks!

Acked-by: Helge Deller <deller@gmx.de> [for parisc] 

