From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 20 Oct 2005 02:31:19 +0000
Subject: Allow simulator to use bigger disks
Message-Id: <17239.375.822659.911150@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The simscsi code at present overflows an int if it's given a large
disk image.  The attached patch increases the possible size to 128G.
While it's unlikely that anyone will want to use SKI with such a
large drive, the same framework is currently being used for various
virtualisation experiments.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

diff --git a/arch/ia64/hp/sim/simscsi.c b/arch/ia64/hp/sim/simscsi.c
--- a/arch/ia64/hp/sim/simscsi.c
+++ b/arch/ia64/hp/sim/simscsi.c
@@ -205,10 +205,11 @@ simscsi_get_disk_size (int fd)
 	char buf[512];
 
 	/*
-	 * This is a bit kludgey: the simulator doesn't provide a direct way of determining
-	 * the disk size, so we do a binary search, assuming a maximum disk size of 4GB.
+	 * This is a bit kludgey: the simulator doesn't provide a
+	 * direct way of determining the disk size, so we do a binary
+	 * search, assuming a maximum disk size of 128GB.
 	 */
-	for (bit = (4UL << 30)/512; bit != 0; bit >>= 1) {
+	for (bit = (128UL << 30)/512; bit != 0; bit >>= 1) {
 		req.addr = __pa(&buf);
 		req.len = sizeof(buf);
 		ia64_ssc(fd, 1, __pa(&req), ((sectors | bit) - 1)*512, SSC_READ);
@@ -225,8 +226,10 @@ simscsi_readwrite10 (struct scsi_cmnd *s
 {
 	unsigned long offset;
 
-	offset = (  (sc->cmnd[2] << 24) | (sc->cmnd[3] << 16)
-		  | (sc->cmnd[4] <<  8) | (sc->cmnd[5] <<  0))*512;
+	offset = (((unsigned long)sc->cmnd[2] << 24) 
+		| ((unsigned long)sc->cmnd[3] << 16)
+		| ((unsigned long)sc->cmnd[4] <<  8) 
+		| ((unsigned long)sc->cmnd[5] <<  0))*512UL;
 	if (sc->use_sg > 0)
 		simscsi_sg_readwrite(sc, mode, offset);
 	else



--
Dr Peter Chubb     http://www.gelato.unsw.edu.au  peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.

