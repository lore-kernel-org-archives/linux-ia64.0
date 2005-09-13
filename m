From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 13 Sep 2005 02:42:31 +0000
Subject: IA64 Simulated Scsi device fails to read_capacity
Message-Id: <17190.15511.931885.257950@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
	As of yesterday morning, Linux 2.6.13+git patches failed to
boot on the simulator.  The symptom was that all the simulated disks
reported zero size.

I believe this is because changes in the SCSI layer now use a
scatterlist for READ_CAPACITY --- sd.c no longer calls scsi_wait_req()
but instead calls scsi_execute_req(), which goes through all the
commotion of building a bio, queuing the command, etc., etc.

simscsi.c doesn't expect a scatterlist for a READ_CAPACITY command.

With the attached patch, it'll boot; but I'm unhappy about the
BUG_ONs.  The second is strictly speaking unnecessary, as if the
request crosses a page boundary then the use_sg count will be two.


 
diff --git a/arch/ia64/hp/sim/simscsi.c b/arch/ia64/hp/sim/simscsi.c
--- a/arch/ia64/hp/sim/simscsi.c
+++ b/arch/ia64/hp/sim/simscsi.c
@@ -310,6 +310,12 @@ simscsi_queuecommand (struct scsi_cmnd *
 				break;
 			}
 			buf = sc->request_buffer;
+			if (sc->use_sg) {
+				struct scatterlist *sl = (struct scatterlist *)sc->buffer;
+				BUG_ON(sc->use_sg != 1);
+				BUG_ON(sl->offset + sc->request_bufflen > PAGE_SIZE);
+				buf = page_address(sl->page) + sl->offset;
+			}
 
 			disk_size = simscsi_get_disk_size(desc[target_id]);
 
