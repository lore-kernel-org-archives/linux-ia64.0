From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 21 Jun 2005 22:51:36 +0000
Subject: RE: scheduler cache-hot-auto-tune patch breaks ia64 UP build
Message-Id: <200506212251.j5LMpag28920@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <032EB457B9DBC540BFB1B7B519C78B0E076E3C6A@orsmsx404.amr.corp.intel.com>
References: <032EB457B9DBC540BFB1B7B519C78B0E076E3C6A@orsmsx404.amr.corp.intel.com>
In-Reply-To: <032EB457B9DBC540BFB1B7B519C78B0E076E3C6A@orsmsx404.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Lynch, Rusty" <rusty.lynch@intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Lynch, Rusty wrote on Tuesday, June 21, 2005 3:04 PM
> Attempting to build 2.6.12-mm1 on ia64 with CONFIG_SMP disabled will
> cause the build to break because max_cache_size is undefined.  I haven't
> spent the time to understand the cache-hot-auto-tune feature, so I don't
> have a patch to fix the problem.

It needs a #ifdef around max_cache_size.  Patch to fix the build problem.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- linux-2.6.12/arch/ia64/kernel/setup.c.orig	2005-06-21 15:46:16.418636538 -0700
+++ linux-2.6.12/arch/ia64/kernel/setup.c	2005-06-21 15:46:34.496761317 -0700
@@ -655,7 +655,9 @@ get_max_cacheline_size (void)
 			cache_size = cci.pcci_cache_size;
         }
   out:
+#ifdef CONFIG_SMP
 	max_cache_size = max(max_cache_size, cache_size);
+#endif
 	if (max > ia64_max_cacheline_size)
 		ia64_max_cacheline_size = max;
 }

