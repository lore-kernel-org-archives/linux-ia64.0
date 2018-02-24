From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Sat, 24 Feb 2018 10:08:23 +0000
Subject: [PATCH] ia64: doc: tweak whitespace for 'console=' parameter
Message-Id: <20180224100823.24671-1-slyfox@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Sergei Trofimovich <slyfox@gentoo.org>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
CC: linux-kernel@vger.kernel.org
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
---
 Documentation/ia64/serial.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/ia64/serial.txt b/Documentation/ia64/serial.txt
index 6869c73de4e2..a63d2c54329b 100644
--- a/Documentation/ia64/serial.txt
+++ b/Documentation/ia64/serial.txt
@@ -111,7 +111,7 @@ TROUBLESHOOTING SERIAL CONSOLE PROBLEMS
 
 	- If you don't have an HCDP, the kernel doesn't know where
 	  your console lives until the driver discovers serial
-	  devices.  Use "console=uart, io,0x3f8" (or appropriate
+	  devices.  Use "console=uart,io,0x3f8" (or appropriate
 	  address for your machine).
 
     Kernel and init script output works fine, but no "login:" prompt:
-- 
2.16.1

