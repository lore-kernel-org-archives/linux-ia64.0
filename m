From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Wed, 21 Mar 2012 21:25:48 +0000
Subject: [PATCH] Documentation/kernel-parameters: remove inttest parameter
Message-Id: <1332365148-3898-1-git-send-email-sebastian@breakpoint.cc>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

According to grep I see no users:
| #git grep inttest
| Documentation/kernel-parameters.txt:    inttest=        [IA-64]

The parameters itself has no description what it supposed to do.
According to the history tree, it was introduced in "[PATCH] Updated
Documentation/kernel-parameters.txt" ("10414c6ddb"). By that time that
parameter had an user. It was removed later by "[PATCH] ia64: SGI SN
update" ("c6bacd5010ec") by Jesse Barnes himself.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
---
 Documentation/kernel-parameters.txt |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index d99fd9c..f65de8f 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1071,8 +1071,6 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			no_x2apic_optout
 				BIOS x2APIC opt-out request will be ignored
 
-	inttest=	[IA-64]
-
 	iomem=		Disable strict checking of access to MMIO memory
 		strict	regions from userspace.
 		relaxed
-- 
1.7.9.1

