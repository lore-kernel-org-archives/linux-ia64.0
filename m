From: Sasha Levin <sashal@kernel.org>
Date: Mon, 29 Mar 2021 22:23:24 +0000
Subject: [PATCH AUTOSEL 4.19 13/15] ia64: fix format strings for err_inject
Message-Id: <20210329222327.2383533-13-sashal@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210329222327.2383533-1-sashal@kernel.org>
In-Reply-To: <20210329222327.2383533-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Sergei Trofimovich <slyfox@gentoo.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-ia64@vger.kernel.org

From: Sergei Trofimovich <slyfox@gentoo.org>

[ Upstream commit 95d44a470a6814207d52dd6312203b0f4ef12710 ]

Fix warning with %lx / u64 mismatch:

  arch/ia64/kernel/err_inject.c: In function 'show_resources':
  arch/ia64/kernel/err_inject.c:62:22: warning:
    format '%lx' expects argument of type 'long unsigned int',
    but argument 3 has type 'u64' {aka 'long long unsigned int'}
     62 |  return sprintf(buf, "%lx", name[cpu]);   \
        |                      ^~~~~~~

Link: https://lkml.kernel.org/r/20210313104312.1548232-1-slyfox@gentoo.org
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/ia64/kernel/err_inject.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/arch/ia64/kernel/err_inject.c b/arch/ia64/kernel/err_inject.c
index 8b5b8e6bc9d9..dd5bfed52031 100644
--- a/arch/ia64/kernel/err_inject.c
+++ b/arch/ia64/kernel/err_inject.c
@@ -59,7 +59,7 @@ show_##name(struct device *dev, struct device_attribute *=
attr,	\
 		char *buf)						\
 {									\
 	u32 cpu=DEv->id;						\
-	return sprintf(buf, "%lx\n", name[cpu]);			\
+	return sprintf(buf, "%llx\n", name[cpu]);			\
 }
=20
 #define store(name)							\
@@ -86,9 +86,9 @@ store_call_start(struct device *dev, struct device_attrib=
ute *attr,
=20
 #ifdef ERR_INJ_DEBUG
 	printk(KERN_DEBUG "pal_mc_err_inject for cpu%d:\n", cpu);
-	printk(KERN_DEBUG "err_type_info=3D%lx,\n", err_type_info[cpu]);
-	printk(KERN_DEBUG "err_struct_info=3D%lx,\n", err_struct_info[cpu]);
-	printk(KERN_DEBUG "err_data_buffer=3D%lx, %lx, %lx.\n",
+	printk(KERN_DEBUG "err_type_info=3D%llx,\n", err_type_info[cpu]);
+	printk(KERN_DEBUG "err_struct_info=3D%llx,\n", err_struct_info[cpu]);
+	printk(KERN_DEBUG "err_data_buffer=3D%llx, %llx, %llx.\n",
 			  err_data_buffer[cpu].data1,
 			  err_data_buffer[cpu].data2,
 			  err_data_buffer[cpu].data3);
@@ -117,8 +117,8 @@ store_call_start(struct device *dev, struct device_attr=
ibute *attr,
=20
 #ifdef ERR_INJ_DEBUG
 	printk(KERN_DEBUG "Returns: status=3D%d,\n", (int)status[cpu]);
-	printk(KERN_DEBUG "capabilities=3D%lx,\n", capabilities[cpu]);
-	printk(KERN_DEBUG "resources=3D%lx\n", resources[cpu]);
+	printk(KERN_DEBUG "capabilities=3D%llx,\n", capabilities[cpu]);
+	printk(KERN_DEBUG "resources=3D%llx\n", resources[cpu]);
 #endif
 	return size;
 }
@@ -131,7 +131,7 @@ show_virtual_to_phys(struct device *dev, struct device_=
attribute *attr,
 			char *buf)
 {
 	unsigned int cpu=DEv->id;
-	return sprintf(buf, "%lx\n", phys_addr[cpu]);
+	return sprintf(buf, "%llx\n", phys_addr[cpu]);
 }
=20
 static ssize_t
@@ -145,7 +145,7 @@ store_virtual_to_phys(struct device *dev, struct device=
_attribute *attr,
 	ret =3D get_user_pages_fast(virt_addr, 1, FOLL_WRITE, NULL);
 	if (ret<=3D0) {
 #ifdef ERR_INJ_DEBUG
-		printk("Virtual address %lx is not existing.\n",virt_addr);
+		printk("Virtual address %llx is not existing.\n", virt_addr);
 #endif
 		return -EINVAL;
 	}
@@ -163,7 +163,7 @@ show_err_data_buffer(struct device *dev,
 {
 	unsigned int cpu=DEv->id;
=20
-	return sprintf(buf, "%lx, %lx, %lx\n",
+	return sprintf(buf, "%llx, %llx, %llx\n",
 			err_data_buffer[cpu].data1,
 			err_data_buffer[cpu].data2,
 			err_data_buffer[cpu].data3);
@@ -178,13 +178,13 @@ store_err_data_buffer(struct device *dev,
 	int ret;
=20
 #ifdef ERR_INJ_DEBUG
-	printk("write err_data_buffer=3D[%lx,%lx,%lx] on cpu%d\n",
+	printk("write err_data_buffer=3D[%llx,%llx,%llx] on cpu%d\n",
 		 err_data_buffer[cpu].data1,
 		 err_data_buffer[cpu].data2,
 		 err_data_buffer[cpu].data3,
 		 cpu);
 #endif
-	ret=3Dsscanf(buf, "%lx, %lx, %lx",
+	ret =3D sscanf(buf, "%llx, %llx, %llx",
 			&err_data_buffer[cpu].data1,
 			&err_data_buffer[cpu].data2,
 			&err_data_buffer[cpu].data3);
--=20
2.30.1
