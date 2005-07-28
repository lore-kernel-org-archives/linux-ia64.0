From: Greg Howard <ghoward@sgi.com>
Date: Thu, 28 Jul 2005 21:04:08 +0000
Subject: Re: [PATCH 2.6.13-rc3] fix unaligned memory access in snsc_event.c
Message-Id: <Pine.SGI.4.58.0507281556350.2100@gallifrey.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.58.0507261138570.39385@gallifrey.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.58.0507261138570.39385@gallifrey.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 26 Jul 2005, Andreas Schwab wrote:

> How about using get_unaligned?

Good idea.  I didn't know this function existed when I submitted
the previous patch.

Here's a revised version:


It's been pointed out that environmental events from the system
controllers on Altix machines cause the kernel to complain about
unaligned memory accesses.  This turns out to be because
"be32_to_cpup()" didn't do everything I thought/hoped it did.
I've added calls to pull the offending integers out of the
buffers using get_unaligned() before feeding them to
be32_to_cpup().

Thanks!
- Greg Howard, SGI

Signed-off-by: Greg Howard <ghoward@sgi.com>

--- 0/drivers/char/snsc_event.c	2005-07-12 23:46:46 -05:00
+++ 1/drivers/char/snsc_event.c	2005-07-28 15:21:03 -05:00
@@ -19,6 +19,7 @@
 #include <linux/sched.h>
 #include <linux/byteorder/generic.h>
 #include <asm/sn/sn_sal.h>
+#include <asm/unaligned.h>
 #include "snsc.h"

 static struct subch_data_s *event_sd;
@@ -62,13 +63,16 @@ static int
 scdrv_parse_event(char *event, int *src, int *code, int *esp_code, char *desc)
 {
 	char *desc_end;
+	__be32 from_buf;

 	/* record event source address */
-	*src = be32_to_cpup((__be32 *)event);
+	from_buf = get_unaligned((__be32 *)event);
+	*src = be32_to_cpup(&from_buf);
 	event += 4; 			/* move on to event code */

 	/* record the system controller's event code */
-	*code = be32_to_cpup((__be32 *)event);
+	from_buf = get_unaligned((__be32 *)event);
+	*code = be32_to_cpup(&from_buf);
 	event += 4;			/* move on to event arguments */

 	/* how many arguments are in the packet? */
@@ -82,7 +86,8 @@ scdrv_parse_event(char *event, int *src,
 		/* not an integer argument, so give up */
 		return -1;
 	}
-	*esp_code = be32_to_cpup((__be32 *)event);
+	from_buf = get_unaligned((__be32 *)event);
+	*esp_code = be32_to_cpup(&from_buf);
 	event += 4;

 	/* parse out the event description */
