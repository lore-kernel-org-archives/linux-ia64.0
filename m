From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 02 Sep 2003 04:57:15 +0000
Subject: qla1280 bandaid
Message-Id: <marc-linux-ia64-106247866314538@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Jes,
   The problem is that bus_reset drops the HOST_LOCK when it calls
schedule_timeout, but when it's called from the initialisation code,
HOST_LOCK isn't actually held.

The appended patch fixes this; however, I'm not sure that it's
correct, because I couldn't work out easily whether the HOST_LOCK is
held or not on all paths to qla1280_bus_reset().

With the patch in place, I can once again boot SMP I2000 and rx4610.

=== drivers/scsi/qla1280.c 1.44 vs edited ==--- 1.44/drivers/scsi/qla1280.c	Fri Aug 15 09:08:54 2003
+++ edited/drivers/scsi/qla1280.c	Tue Sep  2 14:53:32 2003
@@ -3346,9 +3346,9 @@
 			ha->bus_settings[bus].scsi_bus_dead = 1;
 		ha->bus_settings[bus].failed_reset_count++;
 	} else {
-		spin_unlock_irq(HOST_LOCK);
+/*		spin_unlock_irq(HOST_LOCK);*/
 		schedule_timeout(reset_delay * HZ);
-		spin_lock_irq(HOST_LOCK);
+/*		spin_lock_irq(HOST_LOCK);*/
 
 		ha->bus_settings[bus].scsi_bus_dead = 0;
 		ha->bus_settings[bus].failed_reset_count = 0;
