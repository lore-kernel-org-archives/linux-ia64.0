From: Horms <horms@verge.net.au>
Date: Wed, 22 Feb 2006 00:57:55 +0000
Subject: [PATCH] IA64: Document the nomca boot parameter
Message-Id: <20060222005755.GA4903@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

IA64: Document the nomca boot parameter

Signed-Off-By: Horms <horms@verge.net.au>

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index b874771..7520539 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1034,6 +1034,8 @@ running once the system is up.
 
 	nomce		[IA-32] Machine Check Exception
 
+	nomca		[IA-64] Disable machine check abort handling
+
 	noresidual	[PPC] Don't use residual data on PReP machines.
 
 	noresume	[SWSUSP] Disables resume and restores original swap
