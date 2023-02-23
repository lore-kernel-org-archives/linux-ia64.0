From: Randy Dunlap <rdunlap@infradead.org>
Date: Thu, 23 Feb 2023 03:43:09 +0000
Subject: [PATCH] ia64: salinfo: placate defined-but-not-used warning
Message-Id: <20230223034309.13375-1-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-ia64@vger.kernel.org

When CONFIG_PROC_FS is not set, proc_salinfo_show() is not used.
Mark the function as __maybe_unused to quieten the warning message.

../arch/ia64/kernel/salinfo.c:584:12: warning: 'proc_salinfo_show' defined but not used [-Wunused-function]
  584 | static int proc_salinfo_show(struct seq_file *m, void *v)
      |            ^~~~~~~~~~~~~~~~~

Fixes: 3f3942aca6da ("proc: introduce proc_create_single{,_data}")
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: linux-ia64@vger.kernel.org
---
The entire salinfo.c file looks like it should be conditional on
CONFIG_PROC_FS, but I'm just addressing warnings/errors here.

 arch/ia64/kernel/salinfo.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -- a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -581,7 +581,7 @@ static int salinfo_cpu_pre_down(unsigned
  * 'data' contains an integer that corresponds to the feature we're
  * testing
  */
-static int proc_salinfo_show(struct seq_file *m, void *v)
+static int __maybe_unused proc_salinfo_show(struct seq_file *m, void *v)
 {
 	unsigned long data = (unsigned long)v;
 	seq_puts(m, (sal_platform_features & data) ? "1\n" : "0\n");
