From: janitor@sternwelten.at
Date: Wed, 01 Sep 2004 21:24:57 +0000
Subject: [patch 2/2]  minmax-removal 	arch/ia64/hp/sim/simserial.c
Message-Id: <E1C2cbB-0000KK-HX@sputnik>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org




Patch (against 2.6.8.1) removes unnecessary min/max macros and changes
calls to use kernel.h macros instead.

Since I dont have the hardware those patches are not tested.

Best regards
Veeck

Signed-off-by: Michael Veeck <michael.veeck@gmx.net>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/arch/ia64/hp/sim/simserial.c |    6 +-----
 1 files changed, 1 insertion(+), 5 deletions(-)

diff -puN arch/ia64/hp/sim/simserial.c~min-max-arch_ia64_hp_sim_simserial arch/ia64/hp/sim/simserial.c
--- linux-2.6.9-rc1-bk7/arch/ia64/hp/sim/simserial.c~min-max-arch_ia64_hp_sim_simserial	2004-09-01 19:38:19.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/arch/ia64/hp/sim/simserial.c	2004-09-01 19:38:19.000000000 +0200
@@ -50,10 +50,6 @@
 #define _INLINE_ inline
 #endif
 
-#ifndef MIN
-#define MIN(a,b)	((a) < (b) ? (a) : (b))
-#endif
-
 #define IRQ_T(info) ((info->flags & ASYNC_SHARE_IRQ) ? SA_SHIRQ : SA_INTERRUPT)
 
 #define SSC_GETCHAR	21
@@ -275,7 +271,7 @@ static _INLINE_ void transmit_chars(stru
 	 * Then from the beginning of the buffer until necessary
 	 */
 
-	count = MIN(CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE),
+	count = min(CIRC_CNT(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE),
 		    SERIAL_XMIT_SIZE - info->xmit.tail);
 	console->write(console, info->xmit.buf+info->xmit.tail, count);
 

_
