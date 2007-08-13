From: joe@perches.com
Date: Mon, 13 Aug 2007 06:29:12 +0000
Subject: [PATCH] [236/2many] MAINTAINERS - SN-IA64 (Itanium) SUB-PLATFORM
Message-Id: <46bffa38./aNRec9VI7toFMT5%joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-altix@sgi.com, jes@sgi.com, akpm@linux-foundation.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index f68199b..1844d23 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2247,6 +2247,7 @@ L:	linux-altix@sgi.com
 L:	linux-ia64@vger.kernel.org
 W:	http://www.sgi.com/altix
 S:	Maintained
+F:	arch/ia64/sn/
 
 IBM MCA SCSI SUBSYSTEM DRIVER
 P:	Michael Lang
