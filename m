From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 21 Jan 2003 18:58:02 +0000
Subject: [Linux-ia64] elilo-3.3a netbooting patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="wzJLGUyc3ArbnUjN"
Message-Id: <marc-linux-ia64-105590709805737@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--wzJLGUyc3ArbnUjN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

The following patch fixes a problem when netbooting with elilo. Some IP addresses were 
not correctly converted to strings. This problem affects people who are netbooting
AND passing the DHCP-obtained IP address to the kernel using elilo's %I, %M, %N 
substitution variables. Other netbooting configurations should not be affected
by this bug. The patch also includes 2 other minor bug fixes.

The patch is to be applied to elilo-3.3a.

-- 
-Stephane

--wzJLGUyc3ArbnUjN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo-030121.diff"

diff -urN elilo-3.3a/ChangeLog elilo-3.3b/ChangeLog
--- elilo-3.3a/ChangeLog	2002-10-15 10:55:30.000000000 -0700
+++ elilo-3.3b/ChangeLog	2003-01-21 10:52:18.000000000 -0800
@@ -1,3 +1,8 @@
+2003-01-21 Stephane Eranian <eranian@hpl.hp.com>
+	* fix bug in glue_netfs.c convert_ip2decstr() which caused some IP
+	  addresses to be incorrectly converted to strings.
+2002-11-01 Stephane Eranian <eranian@hpl.hp.com>
+	* fix bug in -r option for IA64. There is no argument to this option.
 2002-10-15 Stephane Eranian <eranian@hpl.hp.com>
 	* fixed a double free bug for the kernel memory in case of abort.
 	  (bug spotted by Levent Akyl from Intel)
diff -urN elilo-3.3a/glue_netfs.c elilo-3.3b/glue_netfs.c
--- elilo-3.3a/glue_netfs.c	2002-06-11 09:42:36.000000000 -0700
+++ elilo-3.3b/glue_netfs.c	2003-01-21 10:45:30.000000000 -0800
@@ -82,9 +82,10 @@
 		}
 		val = val % 100;
 		v = val / 10;
-		if (v) {
+		if (v || ip[i] >= 100) {
 			str[j++] = '0'+v;
 		}
+
 		v = val % 10;
 		str[j++] = '0'+v;
 		if (i < l-1) str[j++] = '.';
diff -urN elilo-3.3a/ia32/system.c elilo-3.3b/ia32/system.c
--- elilo-3.3a/ia32/system.c	2002-02-21 17:26:43.000000000 -0800
+++ elilo-3.3b/ia32/system.c	2002-11-06 10:16:45.000000000 -0800
@@ -843,6 +843,17 @@
 		return -1;
 	}
 
+	/* 
+	 * Let's not forget efi info for EFI aware
+	 * IA32 kernels...
+	 */
+	bp->s.efi_sys_tbl = (UINTN)systab;
+	bp->s.efi_mem_map 	= (UINTN)mdesc.md;
+	bp->s.efi_mem_map_size	= mdesc.map_size;
+	bp->s.efi_mem_desc_size = mdesc.desc_size;
+	bp->s.efi_mem_desc_ver 	= mdesc.desc_version;
+	
+
 	*cookie = mdesc.cookie;
 
 	return 0;
diff -urN elilo-3.3a/ia64/config.c elilo-3.3b/ia64/config.c
--- elilo-3.3a/ia64/config.c	2002-08-15 19:08:38.000000000 -0700
+++ elilo-3.3b/ia64/config.c	2002-11-01 09:39:57.000000000 -0800
@@ -96,7 +96,7 @@
 	    || (elilo_opt.sys_img_opts && elilo_opt.sys_img_opts->allow_relocation ==TRUE) ? 1 : 0;
 }
 
-#define IA64_CMDLINE_OPTIONS	L"r:F:"
+#define IA64_CMDLINE_OPTIONS	L"rF:"
 
 CHAR16 *
 sysdeps_get_cmdline_opts(VOID)

--wzJLGUyc3ArbnUjN--

