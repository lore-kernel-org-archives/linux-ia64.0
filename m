From: Jes Sorensen <jes@sgi.com>
Date: Thu, 19 Jan 2006 09:54:00 +0000
Subject: Re: [2.6 patch] drivers/sn/ must be entered for CONFIG_SGI_IOC3
Message-Id: <yq0vewg7dc7.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060117235521.GA14298@redhat.com>
	<20060119032423.GI19398@stusta.de>
In-Reply-To: <20060119032423.GI19398@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: Dave Jones <davej@redhat.com>, pfg@sgi.com, Linux Kernel <linux-kernel@vger.kernel.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org

>>>>> "Adrian" = Adrian Bunk <bunk@stusta.de> writes:

Adrian> On Tue, Jan 17, 2006 at 06:55:21PM -0500, Dave Jones wrote:
>> kernel/drivers/serial/ioc3_serial.ko needs unknown symbol
>> ioc3_unregister_submodule
>> 
>> CONFIG_SERIAL_SGI_IOC3=m CONFIG_SGI_IOC3=m

Adrian> The untested patch below should fix it.

Actually I think this is more appropriate so we don't end up with 17
cases that add drivers/sn to the build lib.

Dave, does this solve the problem?

Cheers,
Jes

Include drivers/sn when CONFIG_IA64_SGI_SN2 or CONFIG_IA64_GENERIC
is enabled.

Signed-off-by: Jes Sorensen <jes@sgi.com>
----

 arch/ia64/Kconfig |    3 +++
 drivers/Makefile  |    2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6/arch/ia64/Kconfig
=================================--- linux-2.6.orig/arch/ia64/Kconfig
+++ linux-2.6/arch/ia64/Kconfig
@@ -374,6 +374,9 @@
 	  To use this option, you have to ensure that the "/proc file system
 	  support" (CONFIG_PROC_FS) is enabled, too.
 
+config SGI_SN
+	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC)
+
 source "drivers/firmware/Kconfig"
 
 source "fs/Kconfig.binfmt"
Index: linux-2.6/drivers/Makefile
=================================--- linux-2.6.orig/drivers/Makefile
+++ linux-2.6/drivers/Makefile
@@ -69,7 +69,7 @@
 obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_MMC)		+= mmc/
 obj-$(CONFIG_INFINIBAND)	+= infiniband/
-obj-$(CONFIG_SGI_IOC4)		+= sn/
+obj-$(CONFIG_SGI_SN)		+= sn/
 obj-y				+= firmware/
 obj-$(CONFIG_CRYPTO)		+= crypto/
 obj-$(CONFIG_SUPERH)		+= sh/
