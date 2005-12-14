From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 14 Dec 2005 21:40:31 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200512142140.jBELeV0X005351@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Second (third?) in the series of "this is the last ia64 pull for 2.6.15".

Please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/process.c |    2 ++
 1 files changed, 2 insertions(+)

Robin Holt:
      [IA64] fix for SET_PERSONALITY when CONFIG_IA32_SUPPORT is not set.

diff-tree 27af4cfd11883073359bd5acab1962b0fa96a3bf (from acd9b7b4e08a3f0f48afa922d8e371414cf2d3b2)
Author: Robin Holt <holt@sgi.com>
Date:   Wed Dec 14 06:58:05 2005 -0600

    [IA64] fix for SET_PERSONALITY when CONFIG_IA32_SUPPORT is not set.
    
    Missed this when fixing the SET_PERSONALITY change.
    
    Signed-off-by: Robin Holt <holt@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index a4da715..e9904c7 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -721,11 +721,13 @@ flush_thread (void)
 	/* drop floating-point and debug-register state if it exists: */
 	current->thread.flags &= ~(IA64_THREAD_FPH_VALID | IA64_THREAD_DBG_VALID);
 	ia64_drop_fpu(current);
+#ifdef CONFIG_IA32_SUPPORT
 	if (IS_IA32_PROCESS(ia64_task_regs(current))) {
 		ia32_drop_partial_page_list(current);
 		current->thread.task_size = IA32_PAGE_OFFSET;
 		set_fs(USER_DS);
 	}
+#endif
 }
 
 /*
