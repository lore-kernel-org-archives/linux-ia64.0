From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 04 Mar 2009 12:05:37 +0000
Subject: [PATCH 06/15] ia64/pv_ops/pvchecker: support mov = ar.itc paravirtualization
Message-Id: <1236168346-29788-7-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1229063944-27462-7-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1229063944-27462-7-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

add suport for mov = ar.itc to pvchecker.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/native/pvchk_inst.h |    5 +++++
 arch/ia64/scripts/pvcheck.sed             |    1 +
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/include/asm/native/pvchk_inst.h b/arch/ia64/include/asm/native/pvchk_inst.h
index b8e6eb1..13b289e 100644
--- a/arch/ia64/include/asm/native/pvchk_inst.h
+++ b/arch/ia64/include/asm/native/pvchk_inst.h
@@ -180,6 +180,11 @@
 	IS_PRED_IN(pred)			\
 	IS_RREG_OUT(reg)			\
 	IS_RREG_CLOB(clob)
+#define MOV_FROM_ITC(pred, pred_clob, reg, clob)	\
+	IS_PRED_IN(pred)				\
+	IS_PRED_CLOB(pred_clob)				\
+	IS_RREG_OUT(reg)				\
+	IS_RREG_CLOB(clob)
 #define MOV_TO_IFA(reg, clob)			\
 	IS_RREG_IN(reg)				\
 	IS_RREG_CLOB(clob)
diff --git a/arch/ia64/scripts/pvcheck.sed b/arch/ia64/scripts/pvcheck.sed
index ba66ac2..e59809a 100644
--- a/arch/ia64/scripts/pvcheck.sed
+++ b/arch/ia64/scripts/pvcheck.sed
@@ -17,6 +17,7 @@ s/mov.*=.*cr\.iip/.warning \"cr.iip should not used directly\"/g
 s/mov.*=.*cr\.ivr/.warning \"cr.ivr should not used directly\"/g
 s/mov.*=[^\.]*psr/.warning \"psr should not used directly\"/g	# avoid ar.fpsr
 s/mov.*=.*ar\.eflags/.warning \"ar.eflags should not used directly\"/g
+s/mov.*=.*ar\.itc.*/.warning \"ar.itc should not used directly\"/g
 s/mov.*cr\.ifa.*=.*/.warning \"cr.ifa should not used directly\"/g
 s/mov.*cr\.itir.*=.*/.warning \"cr.itir should not used directly\"/g
 s/mov.*cr\.iha.*=.*/.warning \"cr.iha should not used directly\"/g
-- 
1.6.0.2

