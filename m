From: Adrian Bunk <bunk@stusta.de>
Date: Thu, 19 Jan 2006 03:24:24 +0000
Subject: [2.6 patch] drivers/sn/ must be entered for CONFIG_SGI_IOC3
Message-Id: <20060119032423.GI19398@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060117235521.GA14298@redhat.com>
In-Reply-To: <20060117235521.GA14298@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Jones <davej@redhat.com>, pfg@sgi.com, Linux Kernel <linux-kernel@vger.kernel.org>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org

On Tue, Jan 17, 2006 at 06:55:21PM -0500, Dave Jones wrote:

> kernel/drivers/serial/ioc3_serial.ko needs unknown symbol ioc3_unregister_submodule
> 
> CONFIG_SERIAL_SGI_IOC3=m
> CONFIG_SGI_IOC3=m

The untested patch below should fix it.

> 		Dave

cu
Adrian


<--  snip  -->


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc1-mm1-full/drivers/Makefile.old	2006-01-19 04:14:24.000000000 +0100
+++ linux-2.6.16-rc1-mm1-full/drivers/Makefile	2006-01-19 04:14:57.000000000 +0100
@@ -70,6 +70,7 @@
 obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_MMC)		+= mmc/
 obj-$(CONFIG_INFINIBAND)	+= infiniband/
+obj-$(CONFIG_SGI_IOC3)		+= sn/
 obj-$(CONFIG_SGI_IOC4)		+= sn/
 obj-y				+= firmware/
 obj-$(CONFIG_CRYPTO)		+= crypto/

