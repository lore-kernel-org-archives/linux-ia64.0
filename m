From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 23 Aug 2006 02:43:27 +0000
Subject: Re: Increase default nodes shift to 10
Message-Id: <Pine.LNX.4.64.0608221940590.26816@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 23 Aug 2006, Horms wrote:

> Actually, given the ammount of memory that is involves, it does
> beg the question of if it needs to be configurable at all.

Thank you. Here is the patch that changes both the NODES_SHIFT
and the NR_CPUS so that even big machines can boot all nodes and
processors with a generic kernel.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4/arch/ia64/Kconfig
=================================--- linux-2.6.18-rc4.orig/arch/ia64/Kconfig	2006-08-06 11:20:11.000000000 -0700
+++ linux-2.6.18-rc4/arch/ia64/Kconfig	2006-08-22 19:40:43.466355915 -0700
@@ -258,7 +258,7 @@ config NR_CPUS
 	int "Maximum number of CPUs (2-1024)"
 	range 2 1024
 	depends on SMP
-	default "64"
+	default "1024"
 	help
 	  You should set this to the number of CPUs in your system, but
 	  keep in mind that a kernel compiled for, e.g., 2 CPUs will boot but
@@ -354,7 +354,7 @@ config NUMA
 config NODES_SHIFT
 	int "Max num nodes shift(3-10)"
 	range 3 10
-	default "8"
+	default "10"
 	depends on NEED_MULTIPLE_NODES
 	help
 	  This option specifies the maximum number of nodes in your SSI system.
