From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 10 Sep 2003 18:42:58 +0000
Subject: small perfmon1 patch for 2.4
MIME-Version: 1
Content-Type: multipart/mixed; boundary="cWoXeonUoKmBZSoM"
Message-Id: <marc-linux-ia64-106321946025751@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

The attached patch fixes a long standing bug in the perfmon-1 implementation
for all 2.4 based kernels.  The PFM_FL_INHERIT_ONCE flag is defined as
allowing a perfmon context to be clone ONCE across fork. Without this
fix, it is in fact clone to all first level child of the parent process.
That's why, for instance, when you run pfmon-2.0 on a command, you see
3 active per-process sessions instead of two (pfmon is multi-threaded).

Bjorn, please apply this patch in your 2.4 tree.

Thanks.

-- 
-Stephane

--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="kernel24-perfmon1-030910.diff"

--- linux-ia64-2.4/arch/ia64/kernel/perfmon.c.old	2003-09-10 11:36:15.000000000 -0700
+++ linux-ia64-2.4/arch/ia64/kernel/perfmon.c	2003-09-10 11:37:01.000000000 -0700
@@ -4013,6 +4013,10 @@
 	if (CTX_INHERIT_MODE(ctx) == PFM_FL_INHERIT_ONCE) {
 		nctx->ctx_fl_inherit = PFM_FL_INHERIT_NONE;
 		DBprintk(("downgrading to INHERIT_NONE for [%d]\n", task->pid));
+		/*
+		 * downgrade parent: once means only first child!
+		 */
+		ctx->ctx_fl_inherit = PFM_FL_INHERIT_NONE;
 	}
 	/*
 	 * task is not yet visible in the tasklist, so we do 

--cWoXeonUoKmBZSoM--
