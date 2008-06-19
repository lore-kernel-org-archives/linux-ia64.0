From: Cliff Wickman <cpw@sgi.com>
Date: Thu, 19 Jun 2008 22:08:14 +0000
Subject: [PATCH] SN2: security hole in sn2_ptc_proc_write
Message-Id: <E1K9SIg-0005n6-Ea@eag09.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



From: Cliff Wickman <cpw@sgi.com>

Security hole in sn2_ptc_proc_write

It is possible to overrun a buffer with a write to this /proc file.

Diffed against 2.6.26-rc5

Signed-off-by: Cliff Wickman <cpw@sgi.com>
---
 arch/ia64/sn/kernel/sn2/sn2_smp.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/arch/ia64/sn/kernel/sn2/sn2_smp.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ linux-2.6/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -512,6 +512,8 @@ static ssize_t sn2_ptc_proc_write(struct
 	int cpu;
 	char optstr[64];
 
+	if (count > 64)
+		return -EINVAL;
 	if (copy_from_user(optstr, user, count))
 		return -EFAULT;
 	optstr[count - 1] = '\0';
