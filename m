From: Kai Germaschewski <kai-germaschewski@uiowa.edu>
Date: Wed, 28 Aug 2002 05:19:05 +0000
Subject: [Linux-ia64] PATCH: 2.5 kconfig synchronise banners 4 (fwd)
Message-Id: <marc-linux-ia64-105590701905989@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Maybe someone here knows an answer? If not, I'll just remove the SN 
specific special casing of devfs]

Hi,

is there any specific reason that SN1/2 have non-standard behavior with 
respect to devfs? If not, I'd prefer to just throw away that special case 
entirely.

--Kai


---------- Forwarded message ----------
Date: Wed, 21 Aug 2002 00:26:05 +1000
From: Greg Banks <gnb@alphalink.com.au>
To: Kai Germaschewski <kai@tp1.ruhr-uni-bochum.de>
Subject: PATCH: 2.5 kconfig synchronise banners 4

G'day,

The symbol CONFIG_DEVFS_DEBUG was defined in two different ways in
arch/ia64/config.in and fs/Config.in, both visible at the same time.
I took the opportunity to move all the devfs stuff out of the ia64
config.in as all of the other architectures let fs/Config.in do it.

diff -ruN --exclude-from=dontdiff linux-2.5.31-orig/arch/ia64/config.in linux-2.5.31/arch/ia64/config.in
--- linux-2.5.31-orig/arch/ia64/config.in	Wed Aug 14 15:02:40 2002
+++ linux-2.5.31/arch/ia64/config.in	Mon Aug 19 22:04:29 2002
@@ -75,10 +75,6 @@
 	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN_SIM
 	bool '  Enable autotest (llsc). Option to run cache test instead of booting' \
 			CONFIG_IA64_SGI_AUTOTEST
-	define_bool CONFIG_DEVFS_FS y
-	if [ "$CONFIG_DEVFS_FS" = "y" ]; then
-	  bool '    Enable DEVFS Debug Code' CONFIG_DEVFS_DEBUG
-	fi
 	bool '  Enable protocol mode for the L1 console' CONFIG_SERIAL_SGI_L1_PROTOCOL
 	define_bool CONFIG_DISCONTIGMEM y
 	define_bool CONFIG_IA64_MCA y
diff -ruN --exclude-from=dontdiff linux-2.5.31-orig/fs/Config.in linux-2.5.31/fs/Config.in
--- linux-2.5.31-orig/fs/Config.in	Wed Aug 14 15:02:40 2002
+++ linux-2.5.31/fs/Config.in	Mon Aug 19 21:52:09 2002
@@ -75,9 +75,13 @@
 
 bool '/proc file system support' CONFIG_PROC_FS
 
-dep_bool '/dev file system support (EXPERIMENTAL)' CONFIG_DEVFS_FS $CONFIG_EXPERIMENTAL
-dep_bool '  Automatically mount at boot' CONFIG_DEVFS_MOUNT $CONFIG_DEVFS_FS
-dep_bool '  Debug devfs' CONFIG_DEVFS_DEBUG $CONFIG_DEVFS_FS
+if [ "$CONFIG_IA64_SGI_SN1" = "y" -o  "$CONFIG_IA64_SGI_SN2" = "y" ]; then
+   define_bool CONFIG_DEVFS_FS y
+else
+   dep_bool '/dev file system support (EXPERIMENTAL)' CONFIG_DEVFS_FS $CONFIG_EXPERIMENTAL
+   dep_bool '  Automatically mount at boot' CONFIG_DEVFS_MOUNT $CONFIG_DEVFS_FS
+fi
+dep_bool '  Enable DEVFS Debug Code' CONFIG_DEVFS_DEBUG $CONFIG_DEVFS_FS
 
 # It compiles as a module for testing only.  It should not be used
 # as a module in general.  If we make this "tristate", a bunch of people


Greg.
-- 
the price of civilisation today is a courageous willingness to prevail,
with force, if necessary, against whatever vicious and uncomprehending
enemies try to strike it down.     - Roger Sandall, The Age, 28Sep2001.




