From: Horms <horms@verge.net.au>
Date: Fri, 12 Jan 2007 06:07:25 +0000
Subject: [PATCH] Kdump documentation update for 2.6.20: ia64 portion
Message-Id: <20070112060724.GC17379@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070112060618.GA17379@verge.net.au>
In-Reply-To: <20070112060618.GA17379@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vivek Goyal <vgoyal@in.ibm.com>
Cc: Mohan Kumar M <mohan@in.ibm.com>, Andrew Morton <akpm@osdl.org>, Nanhai Zou <nanhai.zou@intel.com>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org, linux-ia64@vger.kernel.org

Hi,

this patch fills in the portions for ia64 kexec.

I'm actually not sure what options are required for the dump-capture
kernel, but "init 1 irqpoll maxcpus=1" has been working fine for me.
Or more to the point, I'm not sure if irqpoll is needed or not.

This patch requires the documentation patch update that Vivek Goyal has
been circulating, and I believe is currently in mm. Feel free to fold it
into that change if it makes things easier for anyone.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/Documentation/kdump/kdump.txt
=================================--- linux-2.6.orig/Documentation/kdump/kdump.txt	2007-01-12 14:37:46.000000000 +0900
+++ linux-2.6/Documentation/kdump/kdump.txt	2007-01-12 14:46:53.000000000 +0900
@@ -17,7 +17,7 @@
 memory image to a dump file on the local disk, or across the network to
 a remote system.
 
-Kdump and kexec are currently supported on the x86, x86_64, ppc64 and IA64
+Kdump and kexec are currently supported on the x86, x86_64, ppc64 and ia64
 architectures.
 
 When the system kernel boots, it reserves a small section of memory for
@@ -227,7 +227,11 @@
 
 Dump-capture kernel config options (Arch Dependent, ia64)
 ----------------------------------------------------------
-(To be filled)
+
+- No specific options are required to create a dump-capture kernel
+  for ia64 other than those specified in the arch idependent section
+  above. This means that it is possible to use the system kernel
+  as a dump-capture kernel if desired.
 
 
 Boot into System Kernel
@@ -264,7 +268,8 @@
 For ppc64:
 	- Use vmlinux
 For ia64:
-	(To be filled)
+	- Use vmlinux
+
 
 If you are using a uncompressed vmlinux image then use following command
 to load dump-capture kernel.
@@ -280,18 +285,19 @@
    --initrd=<initrd-for-dump-capture-kernel> \
    --append="root=<root-dev> <arch-specific-options>"
 
+Please note, that --args-linux does not need to be specified for ia64.
+It is planned to make this a no-op on that architecture, but for now
+it should be omitted
+
 Following are the arch specific command line options to be used while
 loading dump-capture kernel.
 
-For i386 and x86_64:
+For i386, x86_64 and ia64:
 	"init 1 irqpoll maxcpus=1"
 
 For ppc64:
 	"init 1 maxcpus=1 noirqdistrib"
 
-For IA64
-	(To be filled)
-
 
 Notes on loading the dump-capture kernel:
 
