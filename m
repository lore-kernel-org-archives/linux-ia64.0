From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Sep 2004 11:17:40 +0000
Subject: Re: [patch 2/2]  minmax-removal 	arch/ia64/hp/sim/simserial.c
Message-Id: <16702.59988.40324.690113@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1C2cbB-0000KK-HX@sputnik>
In-Reply-To: <E1C2cbB-0000KK-HX@sputnik>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

>>>>> On Wed, 01 Sep 2004 23:24:57 +0200, janitor@sternwelten.at said:

  Janitor> Patch (against 2.6.8.1) removes unnecessary min/max macros
  Janitor> and changes calls to use kernel.h macros instead.

I reviewed and tested this patch and approve of it.  Please apply.

Thanks,

	--david

--
ia64: minmax-removal in arch/ia64/hp/sim/simserial.c

Patch (against 2.6.8.1) removes unnecessary min/max macros and changes
calls to use kernel.h macros instead.

Signed-off-by: Michael Veeck <michael.veeck@gmx.net>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

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
