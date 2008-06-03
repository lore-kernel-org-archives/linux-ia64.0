From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 03 Jun 2008 16:22:53 +0000
Subject: RE: [patch] fix bootmem regression on Altix
Message-Id: <1FE6DD409037234FAB833C420AA843EC017C3F7B@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080424181659.GB5211@sgi.com>
In-Reply-To: <20080424181659.GB5211@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Could we get this into mainline? My Altix box won't boot without this
> patch either and applying it on top of all trees after the
> above-mentioned commit is annoying when bisecting. :(

It (well an equivalent patch) is in mainline.  When you are bisecting,
chances are that you'll step into the time period after this was
broken, but before this patch was applied ... so you'll have to look
at sched.c and apply this patch manually when bisect picks a commit
in this zone. But I don't see anyway around that (history is immutable).

-Tony

See this commit:

commit 5a9d3225a0d7060bdf3a18018992dc8cef958425
Author: David Miller <davem@davemloft.net>
Date:   Thu Apr 24 20:46:20 2008 -0700

    sched: use alloc_bootmem() instead of alloc_bootmem_low()
    
    There is no guarantee that there is physical ram below 4GB, and in
    fact many boxes don't have exactly that.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/kernel/sched.c b/kernel/sched.c
index 0014b03..09ca69b 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -8128,7 +8128,7 @@ void __init sched_init(void)
 	 * we use alloc_bootmem().
 	 */
 	if (alloc_size) {
-		ptr = (unsigned long)alloc_bootmem_low(alloc_size);
+		ptr = (unsigned long)alloc_bootmem(alloc_size);
 
 #ifdef CONFIG_FAIR_GROUP_SCHED
 		init_task_group.se = (struct sched_entity **)ptr;
