From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 27 Mar 2006 00:16:56 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <20060327091656.0bb2f2ee.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 26 Mar 2006 11:01:21 -0800
"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:

> Luck, Tony wrote on Friday, March 24, 2006 3:02 PM
> Tony, please queue the following two patches in your next update.  They still
> apply cleanly on Linus' git-tree as of this morning.  Thanks.
>
> [patch] optimize flush_tlb_range on large numa box
> http://marc.theaimsgroup.com/?t4168341600005&r=1&w=2
> 

I love this patch :) Our performance validation team found ia64_global_tlb_purge()
performance problem in do_wp_page()/ia64_global_tlb_purge(), copy-on-write.

When they does fork() at the rate of 4-500 fork/sec, 40% of cpu time was spent in 
copy-on-write's ia64_global_tlb_purge. By this, customer's shell-script cannot scale
enough. (we asked them to reduce fork()..)

(Because they have already removed their test enironment, I can't ask them to try
 this patch. sorry.)

Thanks,
--Kame
