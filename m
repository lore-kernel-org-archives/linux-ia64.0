From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 24 Jul 2001 02:12:58 +0000
Subject: [Linux-ia64] elilo-3.0 PXE mode fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="oC1+HKm2/end4ao3"
Message-Id: <marc-linux-ia64-105590693005888@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--oC1+HKm2/end4ao3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I have identified a problem causing elilo to fail when netbooting from 
a PXE server. Due to a stupid mistake on my part, the config file was
set to the kernel image file when querying the PXE layers.

This problem DOES NOT affect netbooting using regular DHCP server.

The fix is attached to this E-mail.

-- 
-Stephane

--oC1+HKm2/end4ao3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo-010723-2.diff"

--- elilo-3.0/fs/netfs.c	Sun Jul  1 23:14:35 2001
+++ elilo-3.1/fs/netfs.c	Mon Jul 23 19:06:17 2001
@@ -488,7 +488,7 @@
 		length = opts[i+1];
 		if (tag == 71) {
 			server_type =(opts[i+2]<<8) | opts[i+3];
-			Print(L"ServerType: %d\r\n", server_type);
+			DBG_PRINT((L"ServerType: %d\r\n", server_type));
 			return server_type;
 		}
 		i+= 2 + length;
--- elilo-3.0/glue_netfs.c	Sun Jul  1 22:50:35 2001
+++ elilo-3.1/glue_netfs.c	Mon Jul 23 19:04:38 2001
@@ -70,7 +70,7 @@
 			config[maxlen-1] = CHAR_NULL;
 		}
 
-		status = netfs->netfs_query_layer(netfs, 0, NETFS_KERNEL_LAYER, maxlen, config);
+		status = netfs->netfs_query_layer(netfs, 0, NETFS_KERNEL_LAYER, maxlen, kname);
 		if (EFI_ERROR(status)) {
 			StrnCpy(kname, NETFS_DEFAULT_KERNEL, maxlen-1);
 			kname[maxlen-1] = CHAR_NULL;

--oC1+HKm2/end4ao3--

