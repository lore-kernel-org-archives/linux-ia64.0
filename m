From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Fri, 04 Sep 2009 23:58:05 +0000
Subject: [PATCH] mbcs: fix printk format warnings
Message-Id: <20090904165805.0be17c25.randy.dunlap@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

ia64:
drivers/char/mbcs.c:719: warning: format '%lx' expects type 'long unsigned int', but argument 3 has type 'uint64_t'
drivers/char/mbcs.c:719: warning: format '%lx' expects type 'long unsigned int', but argument 4 has type 'uint64_t'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Bruce Losure <blosure@sgi.com>
---
 drivers/char/mbcs.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux-2.6.31-rc8-git1.orig/drivers/char/mbcs.c
+++ linux-2.6.31-rc8-git1/drivers/char/mbcs.c
@@ -15,6 +15,7 @@
 #include <linux/moduleparam.h>
 #include <linux/types.h>
 #include <linux/ioport.h>
+#include <linux/kernel.h>
 #include <linux/notifier.h>
 #include <linux/reboot.h>
 #include <linux/init.h>
@@ -715,8 +716,8 @@ static ssize_t show_algo(struct device *
 	 */
 	debug0 = *(uint64_t *) soft->debug_addr;
 
-	return sprintf(buf, "0x%lx 0x%lx\n",
-		       (debug0 >> 32), (debug0 & 0xffffffff));
+	return sprintf(buf, "0x%x 0x%x\n",
+		       upper_32_bits(debug0), lower_32_bits(debug0));
 }
 
 static ssize_t store_algo(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)



---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
