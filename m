From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 03 Jun 2005 07:52:47 +0000
Subject: Re: periodically-drain-non-local-pagesets-fix.patch added to -mm
Message-Id: <Pine.LNX.4.62.0506030050450.23618@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050602231057.580dcaa3.akpm@osdl.org>
In-Reply-To: <20050602231057.580dcaa3.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 3 Jun 2005, Andrew Morton wrote:

> OK, thanks.  Could someone please spin up a disable-preempt-on-ia64 patch
> for the 2.6.12 release?


Ok. But .... I hope that we all agree on this?

Index: linux-2.6.12-rc5/arch/ia64/Kconfig
=================================--- linux-2.6.12-rc5.orig/arch/ia64/Kconfig	2005-06-02 21:59:26.000000000 -0700
+++ linux-2.6.12-rc5/arch/ia64/Kconfig	2005-06-03 00:49:01.000000000 -0700
@@ -285,7 +285,7 @@ config SCHED_SMT
 	  overhead in some places. If unsure say N here.
 
 config PREEMPT
-	bool "Preemptible Kernel"
+	default n
         help
           This option reduces the latency of the kernel when reacting to
           real-time or interactive events by allowing a low priority process to
