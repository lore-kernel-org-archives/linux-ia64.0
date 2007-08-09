From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 09 Aug 2007 05:53:43 +0000
Subject: Re: [PATCH] flush icache before set_pte() on ia64 take9 [2/2] flush
Message-Id: <20070809145343.d23fb55c.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070809135311.0676a947.kamezawa.hiroyu@jp.fujitsu.com>
	<20070809135721.08841cd7.kamezawa.hiroyu@jp.fujitsu.com>
	<20070808.220838.88002572.davem@davemloft.net>
In-Reply-To: <20070808.220838.88002572.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, Zoltan.Menyhart@bull.net, nickpiggin@yahoo.com.au

On Wed, 08 Aug 2007 22:08:38 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> If this patch works I am very happy with it, since lazy_mmu_prot_update()
> is now completely gone as a result.
> 
> Acked-by: David S. Miller <davem@davemloft.net>
> 

Of course, this patch fixes SIGILL/nfs on Montecito.
At least, passed my test.


Thanks,
-Kame

