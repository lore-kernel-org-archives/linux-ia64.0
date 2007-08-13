From: joe@perches.com
Date: Mon, 13 Aug 2007 06:35:36 +0000
Subject: [PATCH] [429/2many] MAINTAINERS - SGI SN-IA64 (Altix) SERIAL
Message-Id: <46bffbb8.4fakUMLGtqE0GdFV%joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, pfg@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@linux-foundation.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 016cd0c..a4aa6af 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4084,6 +4084,7 @@ P:	Pat Gefre
 M:	pfg@sgi.com
 L:	linux-ia64@vger.kernel.org
 S:	Supported
+F:	Documentation/ia64/serial.txt
 
 SGI VISUAL WORKSTATION 320 AND 540
 P:	Andrey Panin
