From: Takao Indoh <indou.takao@soft.fujitsu.com>
Date: Fri, 23 Jul 2004 09:56:59 +0000
Subject: [PATCH 4/5][Diskdump] IPF(IA64) support
Message-Id: <18C4709B6526CDindou.takao@soft.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <14C4709A99D341indou.takao@soft.fujitsu.com>
In-Reply-To: <14C4709A99D341indou.takao@soft.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

This is a patch for aic79xx driver.


diff -Nur linux-2.6.7.org/drivers/scsi/aic7xxx/aic79xx_osm.c linux-2.6.7/drivers/scsi/aic7xxx/aic79xx_osm.c
--- linux-2.6.7.org/drivers/scsi/aic7xxx/aic79xx_osm.c	2004-06-22 10:27:49.000000000 +0900
+++ linux-2.6.7/drivers/scsi/aic7xxx/aic79xx_osm.c	2004-07-23 15:10:53.129007384 +0900
@@ -786,6 +786,8 @@
 static int	   ahd_linux_bus_reset(Scsi_Cmnd *);
 static int	   ahd_linux_dev_reset(Scsi_Cmnd *);
 static int	   ahd_linux_abort(Scsi_Cmnd *);
+static int	   ahd_linux_sanity_check(struct scsi_device *);
+static void	   ahd_linux_poll(struct scsi_device *);
 
 /*
  * Calculate a safe value for AHD_NSEG (as expressed through ahd_linux_nseg).
@@ -1684,6 +1686,8 @@
 	.slave_alloc		= ahd_linux_slave_alloc,
 	.slave_configure	= ahd_linux_slave_configure,
 	.slave_destroy		= ahd_linux_slave_destroy,
+	.dump_sanity_check	= ahd_linux_sanity_check,
+	.dump_poll		= ahd_linux_poll,
 };
 
 /**************************** Tasklet Handler *********************************/
@@ -4191,6 +4195,39 @@
 	return IRQ_RETVAL(ours);
 }
 
+static int
+ahd_linux_sanity_check(struct scsi_device *device)
+{
+	struct ahd_softc *ahd;
+	struct ahd_linux_device *dev;
+
+	ahd = *(struct ahd_softc **)device->host->hostdata;
+	dev = ahd_linux_get_device(ahd, device->channel,
+				   device->id, device->lun,
+				   /*alloc*/FALSE);
+
+	if (dev = NULL)
+		return -ENXIO;
+	if (ahd->platform_data->qfrozen || dev->qfrozen)
+		return -EBUSY;
+	if (spin_is_locked(&ahd->platform_data->spin_lock))
+		return -EBUSY;
+	return 0;
+}
+
+static void
+ahd_linux_poll(struct scsi_device *device)
+{
+	struct ahd_softc *ahd;
+	int ours;
+
+	ahd = *(struct ahd_softc **)device->host->hostdata;
+	ours = ahd_intr(ahd);
+	if (ahd_linux_next_device_to_run(ahd) != NULL)
+		ahd_schedule_runq(ahd);
+	ahd_linux_run_complete_queue(ahd);
+}
+
 void
 ahd_platform_flushwork(struct ahd_softc *ahd)
 {
