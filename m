From: Yoann Padioleau <padator@wanadoo.fr>
Date: Fri, 27 Jul 2007 09:44:42 +0000
Subject: [PATCH 07/68] 0 -> NULL, for arch/ia64
Message-Id: <200707270944.LAA17193@ifs.emn.fr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-janitors@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org


When comparing a pointer, it's clearer to compare it to NULL than to 0.

Here is an excerpt of the semantic patch: 

@@
expression *E;
@@

  E =
- 0
+ NULL

@@
expression *E;
@@

  E !- 0
+ NULL

Signed-off-by: Yoann Padioleau <padator@wanadoo.fr>
Cc: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org
Cc: akpm@linux-foundation.org
---

 simscsi.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/hp/sim/simscsi.c b/arch/ia64/hp/sim/simscsi.c
index bb87682..64248b5 100644
--- a/arch/ia64/hp/sim/simscsi.c
+++ b/arch/ia64/hp/sim/simscsi.c
@@ -101,7 +101,7 @@ simscsi_interrupt (unsigned long val)
 {
 	struct scsi_cmnd *sc;
 
-	while ((sc = queue[rd].sc) != 0) {
+	while ((sc = queue[rd].sc) != NULL) {
 		atomic_dec(&num_reqs);
 		queue[rd].sc = NULL;
 		if (DBG)

