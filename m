From: Len Brown <lenb@kernel.org>
Date: Tue, 26 Mar 2013 04:29:37 +0000
Subject: [PATCH] ia64 idle: delete (*idle)()
Message-Id: <51512431.9060309@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1360475903-30007-1-git-send-email-lenb@kernel.org> <7dc2a692a27e9c3da86acf150c4a89024e48bd05.1360475150.git.len.brown@intel.com> <5125F3D3.6040309@metafoo.de> <1A7043D5F58CCB44A599DFD55ED4C9482976B321@FMSMSX108.amr.corp.intel.com>
In-Reply-To: <1A7043D5F58CCB44A599DFD55ED4C9482976B321@FMSMSX108.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Lars-Peter Clausen <lars@metafoo.de>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

From: Len Brown <len.brown@intel.com>

3e7fc708eb (ia64 idle: delete pm_idle) in 3.9-rc1
didn't finish the job, leaving an un-initialized
reference to (*idle)().

Reported-by: Lars-Peter Clausen <lars@metafoo.de>
Signed-off-by: Len Brown <len.brown@intel.com>
---
 arch/ia64/kernel/process.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index e34f565..6f7dc8b 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -291,7 +291,6 @@ cpu_idle (void)
 		}
 
 		if (!need_resched()) {
-			void (*idle)(void);
 #ifdef CONFIG_SMP
 			min_xtp();
 #endif
@@ -299,9 +298,7 @@ cpu_idle (void)
 			if (mark_idle)
 				(*mark_idle)(1);
 
-			if (!idle)
-				idle = default_idle;
-			(*idle)();
+			default_idle();
 			if (mark_idle)
 				(*mark_idle)(0);
 #ifdef CONFIG_SMP
-- 

