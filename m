From: Doug Chapman <doug.chapman@hp.com>
Date: Thu, 19 Jul 2007 17:15:29 +0000
Subject: [PATCH] ia64: fix build failure on fs/quota.c
Message-Id: <1184865329.3825.25.camel@dchapman.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, vtaras@openvz.org


Fix ia64 build failure on fs/qutoa.c.  A recent patch used the
type compat_u64 which on ia64 is only available if CONFIG_COMPAT
is defined.


From: Tony Luck <tony.luck@intel.com>
Signed-off-by: Doug Chapman <doug.chapman@hp.com>

--

--- a/fs/quota.c
+++ b/fs/quota.c
@@ -387,7 +387,7 @@ asmlinkage long sys_quotactl(unsigned int cmd, const char __user *special, qid_t
        return ret;
 }
 
-#if defined(CONFIG_X86_64) || defined(CONFIG_IA64)
+#if defined(CONFIG_X86_64) || (defined(CONFIG_IA64) && defined(CONFIG_COMPAT))
 /*
  * This code works only for 32 bit quota tools over 64 bit OS (x86_64, ia64)
  * and is necessary due to alignment problems.



