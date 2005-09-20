From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Tue, 20 Sep 2005 22:07:01 +0000
Subject: Re: [patch] MCA recovery verify pfn_valid
Message-Id: <200509202207.j8KM71U62780159@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509162154.j8GLsrWN2681135@efs.americas.sgi.com>
In-Reply-To: <200509162154.j8GLsrWN2681135@efs.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hidetoshi Seto wrote:
> 
> How about this?
> 
> Thanks,
> H.Seto
> 
> Verify the pfn is valid before calling pfn_to_page(),
> and cut isolation message if nothing was done.
> 
> Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

Looks good to me.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
