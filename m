From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 01 Aug 2006 23:27:02 +0000
Subject: Fix build for SKI simulator
Message-Id: <17615.58182.343793.999423@berry.ken.nicta.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi folks,
	The recent chanegs to the SCSI command structure mean that the
simscsi driver doesn't build any more.  Here's the patch to fix it.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

diff --git a/arch/ia64/hp/sim/simscsi.c b/arch/ia64/hp/sim/simscsi.c
index a3fe975..8a4f0d0 100644
--- a/arch/ia64/hp/sim/simscsi.c
+++ b/arch/ia64/hp/sim/simscsi.c
@@ -151,7 +151,7 @@ static void
 simscsi_sg_readwrite (struct scsi_cmnd *sc, int mode, unsigned long offset)
 {
 	int list_len = sc->use_sg;
-	struct scatterlist *sl = (struct scatterlist *)sc->buffer;
+	struct scatterlist *sl = (struct scatterlist *)sc->request_buffer;
 	struct disk_stat stat;
 	struct disk_req req;
 
@@ -244,7 +244,7 @@ static void simscsi_fillresult(struct sc
 
 	if (scatterlen = 0)
 		memcpy(sc->request_buffer, buf, len);
-	else for (slp = (struct scatterlist *)sc->buffer; scatterlen-- > 0 && len > 0; slp++) {
+	else for (slp = (struct scatterlist *)sc->request_buffer; scatterlen-- > 0 && len > 0; slp++) {
 		unsigned thislen = min(len, slp->length);
 
 		memcpy(page_address(slp->page) + slp->offset, buf, thislen);




--
Dr Peter Chubb     http://www.gelato.unsw.edu.au  peterc@gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia

