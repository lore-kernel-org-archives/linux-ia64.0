From: Tejun Heo <tj@kernel.org>
Date: Thu, 29 Oct 2009 14:03:31 +0000
Subject: [PATCH percpu#for-next] ia64: add sparse annotation to __ia64_per_cpu_var()
Message-Id: <4AE9A0B3.4010305@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Christoph Lameter <cl@linux-foundation.org>

ia64 has its own optimized percpu accessor - __ia64_per_cpu_var().
Add percpu sparse annotations to it.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 arch/ia64/include/asm/percpu.h |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: work/arch/ia64/include/asm/percpu.h
=================================--- work.orig/arch/ia64/include/asm/percpu.h
+++ work/arch/ia64/include/asm/percpu.h
@@ -39,7 +39,10 @@ extern void *per_cpu_init(void);
  * On the positive side, using __ia64_per_cpu_var() instead of __get_cpu_var() is slightly
  * more efficient.
  */
-#define __ia64_per_cpu_var(var)	var
+#define __ia64_per_cpu_var(var) (*({					\
+	__verify_pcpu_ptr(&(var));					\
+	((typeof(var) __kernel __force *)&(var));			\
+}))
 
 #include <asm-generic/percpu.h>
 
