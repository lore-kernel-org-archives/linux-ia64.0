From: Takao Indoh <indou.takao@soft.fujitsu.com>
Date: Fri, 23 Jul 2004 09:55:21 +0000
Subject: [PATCH 3/5][Diskdump] IPF(IA64) support
Message-Id: <17C4709B2AEF41indou.takao@soft.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <14C4709A99D341indou.takao@soft.fujitsu.com>
In-Reply-To: <14C4709A99D341indou.takao@soft.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

This is a patch for aic7xxx driver.


diff -Nur linux-2.6.7.org/drivers/scsi/aic7xxx/aic7xxx_osm.c linux-2.6.7/drivers/scsi/aic7xxx/aic7xxx_osm.c
--- linux-2.6.7.org/drivers/scsi/aic7xxx/aic7xxx_osm.c	2004-06-22 10:27:49.000000000 +0900
+++ linux-2.6.7/drivers/scsi/aic7xxx/aic7xxx_osm.c	2004-07-23 15:10:53.132006928 +0900
@@ -774,6 +774,8 @@
 static int	   ahc_linux_bus_reset(Scsi_Cmnd *);
 static int	   ahc_linux_dev_reset(Scsi_Cmnd *);
 static int	   ahc_linux_abort(Scsi_Cmnd *);
+static int	   ahc_linux_sanity_check(struct scsi_device *);
+static void	   ahc_linux_poll(struct scsi_device *);
 
 /*
  * Calculate a safe value for AHC_NSEG (as expressed through ahc_linux_nseg).
@@ -1315,6 +1317,8 @@
 	.slave_alloc		= ahc_linux_slave_alloc,
 	.slave_configure	= ahc_linux_slave_configure,
 	.slave_destroy		= ahc_linux_slave_destroy,
+	.dump_sanity_check	= ahc_linux_sanity_check,
+	.dump_poll		= ahc_linux_poll,
 };
 
 /**************************** Tasklet Handler *********************************/
@@ -3868,6 +3872,41 @@
 	return IRQ_RETVAL(ours);
 }
 
+static int
+ahc_linux_sanity_check(struct scsi_device *device)
+{
+	struct ahc_softc *ahc;
+	struct ahc_linux_device *dev;
+
+	ahc = *(struct ahc_softc **)device->host->hostdata;
+	dev = ahc_linux_get_device(ahc, device->channel,
+				   device->id, device->lun,
+					   /*alloc*/FALSE);
+	if (dev = NULL)
+		return -ENXIO;
+	if (ahc->platform_data->qfrozen || dev->qfrozen)
+		return -EBUSY;
+	if (spin_is_locked(&ahc->platform_data->spin_lock))
+		return -EBUSY;
+	return 0;
+}
+
+static void
+ahc_linux_poll(struct scsi_device *device)
+{
+	struct ahc_softc *ahc;
+	struct ahc_linux_device *dev;
+
+	ahc = *(struct ahc_softc **)device->host->hostdata;
+	ahc_intr(ahc);
+	while ((dev = ahc_linux_next_device_to_run(ahc)) != NULL) {
+		TAILQ_REMOVE(&ahc->platform_data->device_runq, dev, links);
+		dev->flags &= ~AHC_DEV_ON_RUN_LIST;
+		ahc_linux_check_device_queue(ahc, dev);
+	}
+	ahc_linux_run_complete_queue(ahc);
+}
+
 void
 ahc_platform_flushwork(struct ahc_softc *ahc)
 {
