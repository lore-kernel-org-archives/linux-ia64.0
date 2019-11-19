From: Sean Christopherson <sean.j.christopherson@intel.com>
Date: Tue, 19 Nov 2019 00:21:15 +0000
Subject: [PATCH 06/12] efi/capsule-loader: Explicitly include linux/io.h for page_to_phys()
Message-Id: <20191119002121.4107-7-sean.j.christopherson@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191119002121.4107-1-sean.j.christopherson@intel.com>
In-Reply-To: <20191119002121.4107-1-sean.j.christopherson@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Steven Rostedt <rostedt@goodmis.org>, Ard Biesheuvel <ardb@kernel.org>, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Nadav Amit <namit@vmware.com>, "VMware, Inc." <pv-drivers@vmware.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans de Goede <hdegoede@redhat.com>, Cezary Rojewski <cezary.rojewski@intel.com>, Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>, Liam Girdwood <liam.r.girdwood@linux.intel.com>, Jie Yang <yang.jie@linux.intel.com>, Mark Brown <broonie@kernel.org>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-efi@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-acpi@vger.kernel.org, alsa-devel@alsa-project.org

Through a labyrinthian sequence of includes, usage of page_to_phys() is
dependent on the include of asm/io.h in x86's asm/realmode.h, which is
included in x86's asm/acpi.h and thus by linux/acpi.h.  Explicitly
include linux/io.h to break the dependency on realmode.h so that a
future patch can remove the realmode.h include from acpi.h without
breaking the build.

Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>
---
 drivers/firmware/efi/capsule-loader.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/firmware/efi/capsule-loader.c b/drivers/firmware/efi/capsule-loader.c
index b1395133389e..d3067cbd5114 100644
--- a/drivers/firmware/efi/capsule-loader.c
+++ b/drivers/firmware/efi/capsule-loader.c
@@ -11,6 +11,7 @@
 #include <linux/module.h>
 #include <linux/miscdevice.h>
 #include <linux/highmem.h>
+#include <linux/io.h>
 #include <linux/slab.h>
 #include <linux/mutex.h>
 #include <linux/efi.h>
-- 
2.24.0
