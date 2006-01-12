From: Adrian Bunk <bunk@stusta.de>
Date: Thu, 12 Jan 2006 01:02:40 +0000
Subject: [-mm patch] fix arch/ia64/sn/kernel/tiocx.c compilation
Message-Id: <20060112010240.GN29663@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060111042135.24faf878.akpm@osdl.org>
In-Reply-To: <20060111042135.24faf878.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Russell King <rmk@arm.linux.org.uk>, Greg K-H <greg@kroah.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Wed, Jan 11, 2006 at 04:21:35AM -0800, Andrew Morton wrote:
>...
> Changes since 2.6.15-mm2:
>...
> +gregkh-driver-add-tiocx-bus_type-probe-remove-methods.patch
>...
>  driver tree updates
>...

This patch caused the following compile error:

<--  snip  -->

...
  CC      arch/ia64/sn/kernel/tiocx.o
arch/ia64/sn/kernel/tiocx.c:151: error: 'cx_device_remove' undeclared here (not in a function)
make[2]: *** [arch/ia64/sn/kernel/tiocx.o] Error 1

<--  snip  -->


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.15-mm3/arch/ia64/sn/kernel/tiocx.c.old	2006-01-12 01:58:20.000000000 +0100
+++ linux-2.6.15-mm3/arch/ia64/sn/kernel/tiocx.c	2006-01-12 01:58:35.000000000 +0100
@@ -148,7 +148,7 @@
 	.match = tiocx_match,
 	.uevent = tiocx_uevent,
 	.probe = cx_device_probe,
-	.remove = cx_device_remove,
+	.remove = cx_driver_remove,
 };
 
 /**

