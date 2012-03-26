From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Mon, 26 Mar 2012 19:28:33 +0000
Subject: [PATCH] Documentation/kernel-parameters: remove autotest and mcatest
Message-Id: <20120326192833.GA5470@breakpoint.cc>
List-Id: <linux-ia64.vger.kernel.org>
References: <1332365148-3898-1-git-send-email-sebastian@breakpoint.cc>
In-Reply-To: <1332365148-3898-1-git-send-email-sebastian@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It has no more users, the last one is gone in "[PATCH] ia64: Kconfig
cleanup" aka ("6fd79ab50b").
mcatest is gone in commit "[PATCH] ia64: SGI SN update"
("c6bacd5010ec").

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
---
Nice. I have two more for you :)

 Documentation/kernel-parameters.txt |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index f65de8f..8a17faa 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -397,8 +397,6 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	atkbd.softrepeat= [HW]
 			Use software keyboard repeat
 
-	autotest	[IA-64]
-
 	baycom_epp=	[HW,AX25]
 			Format: <io>,<mode>
 
@@ -1410,8 +1408,6 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			devices can be requested on-demand with the
 			/dev/loop-control interface.
 
-	mcatest=	[IA-64]
-
 	mce		[X86-32] Machine Check Exception
 
 	mce=option	[X86-64] See Documentation/x86/x86_64/boot-options.txt
-- 
1.7.9.1
