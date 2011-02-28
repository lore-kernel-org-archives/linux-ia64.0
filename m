From: "Justin P. Mattock" <justinmattock@gmail.com>
Date: Mon, 28 Feb 2011 04:46:46 +0000
Subject: [PATCH v3 02/21]arch:ia64:setup.c Typo fix  Architechtuallly
Message-Id: <1298868406-4108-1-git-send-email-justinmattock@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: trivial@kernel.org
Cc: jes@sgi.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, joe@perches.com, hans.boehm@hp.com, "Justin P. Mattock" <justinmattock@gmail.com>

The below patch(hopefully)fixes a typo in a comment.

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 arch/ia64/sn/kernel/setup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index dbc4cbe..77db0b5 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -592,7 +592,7 @@ void __cpuinit sn_cpu_init(void)
 	/*
 	 * Don't check status. The SAL call is not supported on all PROMs
 	 * but a failure is harmless.
-	 * Architechtuallly, cpu_init is always called twice on cpu 0. We
+	 * Architecturally, cpu_init is always called twice on cpu 0. We
 	 * should set cpu_number on cpu 0 once.
 	 */
 	if (cpuid = 0) {
-- 
1.7.4.1

