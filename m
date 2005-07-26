From: Greg Howard <ghoward@sgi.com>
Date: Tue, 26 Jul 2005 17:03:46 +0000
Subject: [PATCH 2.6.13-rc3] fix unaligned memory access in snsc_event.c
Message-Id: <Pine.SGI.4.58.0507261138570.39385@gallifrey.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

It's been pointed out that environmental events from the system
controllers on Altix machines cause the kernel to complain about
unaligned memory accesses.  This turns out to be because
"be32_to_cpup()" didn't do everything I thought/hoped it did.
I've added a new function to the file that copies a (big-endian)
integer out of a byte buffer and into a little-endian integer
variable.  Please apply the following patch if it looks right to
you.

Thanks!
- Greg Howard, SGI

Signed-off-by: Greg Howard <ghoward@sgi.com>

diff -uprN -X 0/Documentation/dontdiff 0/drivers/char/snsc_event.c 1/drivers/char/snsc_event.c
--- 0/drivers/char/snsc_event.c	2005-07-12 23:46:46 -05:00
+++ 1/drivers/char/snsc_event.c	2005-07-26 11:34:06 -05:00
@@ -26,6 +26,18 @@ static struct subch_data_s *event_sd;
 void scdrv_event(unsigned long);
 DECLARE_TASKLET(sn_sysctl_event, scdrv_event, 0);

+static int
+copy_buffer_to_int(char *buffer)
+{
+	int i, result = 0;
+	for(i = 0; i < sizeof(result); i++ ) {
+		result |= ((unsigned)(*(unsigned char *)buffer++)
+				<< (8 * ((sizeof(result) - i) - 1)));
+	}
+	return result;
+}
+
+
 /*
  * scdrv_event_interrupt
  *
@@ -64,11 +76,11 @@ scdrv_parse_event(char *event, int *src,
 	char *desc_end;

 	/* record event source address */
-	*src = be32_to_cpup((__be32 *)event);
+	*src = copy_buffer_to_int(event);
 	event += 4; 			/* move on to event code */

 	/* record the system controller's event code */
-	*code = be32_to_cpup((__be32 *)event);
+	*code = copy_buffer_to_int(event);
 	event += 4;			/* move on to event arguments */

 	/* how many arguments are in the packet? */
@@ -82,7 +94,7 @@ scdrv_parse_event(char *event, int *src,
 		/* not an integer argument, so give up */
 		return -1;
 	}
-	*esp_code = be32_to_cpup((__be32 *)event);
+	*esp_code = copy_buffer_to_int(event);
 	event += 4;

 	/* parse out the event description */
