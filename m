From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sun, 01 Jun 2014 21:43:39 +0000
Subject: [PATCH] arch: ia64: kernel: palinfo.c:  Optimization of the Code
Message-Id: <1401659019-17586-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>, Paul Gortmaker <paul.gortmaker@windriver.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From what I know, AND is faster then modulo.
Not sure if this is worth changing though.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 arch/ia64/kernel/palinfo.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index c39c3cd..7915b02 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -156,7 +156,8 @@ static void bitregister_process(struct seq_file *m, u64 *reg_info, int max)
 
 	for(; i < max; i++ ) {
 
-		if (i != 0 && (i%64) = 0) value = *++reg_info;
+		if (i != 0 && (i&63) = 0)
+			value = *++reg_info;
 
 		if ((value & 0x1) = 0 && skip = 0) {
 			if (begin  <= i - 2)
-- 
1.7.10.4

