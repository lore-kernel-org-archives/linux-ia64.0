From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 15 Sep 2005 05:35:03 +0000
Subject: Fix simscsi for new SCSI midlayer
Message-Id: <17193.2055.852485.3865@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The sd driver now uses scsi_execute_req() for almost everything.
scsi_execute_req() converts requests into scatterlists.

The appended patch fixes the HP SCSI disk simulator to understand
scatterlists for more commands.


Without this patch the current kernel will not boot on the simulator
(the discs are always detected as having no sectors, and so cannot be
mounted)

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>


Index: linux-2.6-import/arch/ia64/hp/sim/simscsi.c
=================================--- linux-2.6-import.orig/arch/ia64/hp/sim/simscsi.c	2005-09-15 12:55:15.268737159 +1000
+++ linux-2.6-import/arch/ia64/hp/sim/simscsi.c	2005-09-15 15:30:23.632627751 +1000
@@ -226,27 +226,45 @@ simscsi_readwrite10 (struct scsi_cmnd *s
 	unsigned long offset;
 
 	offset = (  (sc->cmnd[2] << 24) | (sc->cmnd[3] << 16)
 		  | (sc->cmnd[4] <<  8) | (sc->cmnd[5] <<  0))*512;
 	if (sc->use_sg > 0)
 		simscsi_sg_readwrite(sc, mode, offset);
 	else
 		simscsi_readwrite(sc, mode, offset, ((sc->cmnd[7] << 8) | sc->cmnd[8])*512);
 }
 
+static void simscsi_fillresult(struct scsi_cmnd *sc, char *buf, unsigned len)
+{
+
+	int scatterlen = sc->use_sg;
+	struct scatterlist *slp;
+
+	if (scatterlen = 0)
+		memcpy(sc->request_buffer, buf, len);
+	else for (slp = (struct scatterlist *)sc->buffer; scatterlen-- > 0 && len > 0; slp++) {
+		unsigned thislen = min(len, slp->length);
+
+		memcpy(page_address(slp->page) + slp->offset, buf, thislen);
+		slp++;
+		len -= thislen;
+	}
+}
+
 static int
 simscsi_queuecommand (struct scsi_cmnd *sc, void (*done)(struct scsi_cmnd *))
 {
 	unsigned int target_id = sc->device->id;
 	char fname[MAX_ROOT_LEN+16];
 	size_t disk_size;
 	char *buf;
+	char localbuf[60];
 #if DEBUG_SIMSCSI
 	register long sp asm ("sp");
 
 	if (DBG)
 		printk("simscsi_queuecommand: target=%d,cmnd=%u,sc=%lu,sp=%lx,done=%p\n",
 		       target_id, sc->cmnd[0], sc->serial_number, sp, done);
 #endif
 
 	sc->result = DID_BAD_TARGET << 16;
 	sc->scsi_done = done;
@@ -256,30 +274,31 @@ simscsi_queuecommand (struct scsi_cmnd *
 			if (sc->request_bufflen < 35) {
 				break;
 			}
 			sprintf (fname, "%s%c", simscsi_root, 'a' + target_id);
 			desc[target_id] = ia64_ssc(__pa(fname), SSC_READ_ACCESS|SSC_WRITE_ACCESS,
 						   0, 0, SSC_OPEN);
 			if (desc[target_id] < 0) {
 				/* disk doesn't exist... */
 				break;
 			}
-			buf = sc->request_buffer;
+			buf = localbuf;
 			buf[0] = 0;	/* magnetic disk */
 			buf[1] = 0;	/* not a removable medium */
 			buf[2] = 2;	/* SCSI-2 compliant device */
 			buf[3] = 2;	/* SCSI-2 response data format */
 			buf[4] = 31;	/* additional length (bytes) */
 			buf[5] = 0;	/* reserved */
 			buf[6] = 0;	/* reserved */
 			buf[7] = 0;	/* various flags */
 			memcpy(buf + 8, "HP      SIMULATED DISK  0.00",  28);
+			simscsi_fillresult(sc, buf, 34);
 			sc->result = GOOD;
 			break;
 
 		      case TEST_UNIT_READY:
 			sc->result = GOOD;
 			break;
 
 		      case READ_6:
 			if (desc[target_id] < 0 )
 				break;
@@ -297,46 +316,44 @@ simscsi_queuecommand (struct scsi_cmnd *
 				break;
 			simscsi_readwrite6(sc, SSC_WRITE);
 			break;
 
 		      case WRITE_10:
 			if (desc[target_id] < 0)
 				break;
 			simscsi_readwrite10(sc, SSC_WRITE);
 			break;
 
-
 		      case READ_CAPACITY:
 			if (desc[target_id] < 0 || sc->request_bufflen < 8) {
 				break;
 			}
-			buf = sc->request_buffer;
-
+			buf = localbuf;
 			disk_size = simscsi_get_disk_size(desc[target_id]);
 
-			/* pretend to be a 1GB disk (partition table contains real stuff): */
 			buf[0] = (disk_size >> 24) & 0xff;
 			buf[1] = (disk_size >> 16) & 0xff;
 			buf[2] = (disk_size >>  8) & 0xff;
 			buf[3] = (disk_size >>  0) & 0xff;
 			/* set block size of 512 bytes: */
 			buf[4] = 0;
 			buf[5] = 0;
 			buf[6] = 2;
 			buf[7] = 0;
+			simscsi_fillresult(sc, buf, 8);
 			sc->result = GOOD;
 			break;
 
 		      case MODE_SENSE:
 		      case MODE_SENSE_10:
 			/* sd.c uses this to determine whether disk does write-caching. */
-			memset(sc->request_buffer, 0, 128);
+			simscsi_fillresult(sc, (char *)empty_zero_page, sc->request_bufflen);
 			sc->result = GOOD;
 			break;
 
 		      case START_STOP:
 			printk(KERN_ERR "START_STOP\n");
 			break;
 
 		      default:
 			panic("simscsi: unknown SCSI command %u\n", sc->cmnd[0]);
 		}
