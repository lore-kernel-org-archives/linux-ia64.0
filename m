From: domen@coderock.org
Date: Mon, 10 Jan 2005 19:46:38 +0000
Subject: [patch 3/3] sn_hwperf.c - vfree() checking cleanups
Message-Id: <20050110194638.9154C1F20A@trashy.coderock.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



sn_hwperf.c vfree() checking cleanups.

Signed-off by: James Lamanna <jlamanna@gmail.com>


Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/arch/ia64/sn/kernel/sn2/sn_hwperf.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff -puN arch/ia64/sn/kernel/sn2/sn_hwperf.c~vfree-arch_ia64_sn_kernel_sn2_sn_hwperf arch/ia64/sn/kernel/sn2/sn_hwperf.c
--- kj/arch/ia64/sn/kernel/sn2/sn_hwperf.c~vfree-arch_ia64_sn_kernel_sn2_sn_hwperf	2005-01-10 18:00:56.000000000 +0100
+++ kj-domen/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-01-10 18:00:56.000000000 +0100
@@ -529,8 +529,7 @@ sn_hwperf_ioctl(struct inode *in, struct
 	}
 
 error:
-	if (p)
-		vfree(p);
+	vfree(p);
 
 	lock_kernel();
 	return r;
@@ -641,7 +640,6 @@ int sn_topology_release(struct inode *in
 {
 	struct seq_file *seq = file->private_data;
 
-	if (seq->private)
-		vfree(seq->private);
+	vfree(seq->private);
 	return seq_release(inode, file);
 }
_
