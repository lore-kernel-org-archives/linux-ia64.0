From: dcn@sgi.com (Dean Nelson)
Date: Thu, 08 Sep 2005 15:46:58 +0000
Subject: [PATCH] ensure XPC and XPNET are loaded on sn2 platforms only
Message-Id: <43205CF2.mailx6N91YXFZ1@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

These are SN2 only drivers.  They should have platform checks to prevent
them from doing evil stuff in GENERIC kernels.

Signed-off-by: Martin Hicks <mort@sgi.com>
Acked-by: Dean Nelson <dcn@sgi.com>


 arch/ia64/sn/kernel/xpc_main.c |    4 ++++
 arch/ia64/sn/kernel/xpnet.c    |    4 ++++
 2 files changed, 8 insertions(+)


Index: linux-2.6/arch/ia64/sn/kernel/xpc_main.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_main.c	2005-09-08 06:58:26.134622631 -0500
+++ linux-2.6/arch/ia64/sn/kernel/xpc_main.c	2005-09-08 09:47:31.081587119 -0500
@@ -885,6 +885,10 @@
 	pid_t pid;
 
 
+	if (!ia64_platform_is("sn2")) {
+		return -ENODEV;
+	}
+
 	/*
 	 * xpc_remote_copy_buffer is used as a temporary buffer for bte_copy'ng
 	 * both a partition's reserved page and its XPC variables. Its size was
Index: linux-2.6/arch/ia64/sn/kernel/xpnet.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpnet.c	2005-09-08 06:58:26.136575561 -0500
+++ linux-2.6/arch/ia64/sn/kernel/xpnet.c	2005-09-08 09:47:36.693330520 -0500
@@ -636,6 +636,10 @@
 	int result = -ENOMEM;
 
 
+	if (!ia64_platform_is("sn2")) {
+		return -ENODEV;
+	}
+
 	dev_info(xpnet, "registering network device %s\n", XPNET_DEVICE_NAME);
 
 	/*
