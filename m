From: Russ Anderson <rja@sgi.com>
Date: Fri, 15 Sep 2006 03:12:45 +0000
Subject: Re: [PATCH] printing support for MCA/INIT
Message-Id: <200609150312.k8F3Cj8i4513464@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4486BE32.80100@jp.fujitsu.com>
In-Reply-To: <4486BE32.80100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Acked-by: Russ Anderson <rja@sgi.com>

Hidetoshi Seto wrote:
>
> Here is the latest updated patch.
> Let me express my appreciation to Russ for all the advice
> and help.
> 
> Thanks,
> H.Seto
> 
> -----
> 
> Printing message to console from MCA/INIT handler is useful,
> however doing oops_in_progress = 1 in them exactly makes
> something in kernel wrong. Especially it sounds ugly if
> system goes wrong after returning from recoverable MCA.
> 
> This patch adds ia64_mca_printk() function that collects
> messages into temporary-not-so-large message buffer during
> in MCA/INIT environment and print them out later, after
> returning to normal context or when handlers determine to
> down the system.
> 
> Also this print function is exported for use in extensional
> MCA handler. It would be useful to describe detail about
> recovery.
> 
> NOTE:
> I don't think it is sane thing if temporary message buffer
> is enlarged enough to hold whole stack dumps from INIT, so
> buffering is disabled during stack dump from INIT-monarch
> (= default_monarch_init_process). please fix it in future.
> 
> Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
