From: Sean Christopherson <sean.j.christopherson@intel.com>
Date: Tue, 19 Nov 2019 00:21:10 +0000
Subject: [PATCH 01/12] x86/efi: Explicitly include realmode.h to handle RM trampoline quirk
Message-Id: <20191119002121.4107-2-sean.j.christopherson@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191119002121.4107-1-sean.j.christopherson@intel.com>
In-Reply-To: <20191119002121.4107-1-sean.j.christopherson@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Steven Rostedt <rostedt@goodmis.org>, Ard Biesheuvel <ardb@kernel.org>, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Nadav Amit <namit@vmware.com>, "VMware, Inc." <pv-drivers@vmware.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans de Goede <hdegoede@redhat.com>, Cezary Rojewski <cezary.rojewski@intel.com>, Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>, Liam Girdwood <liam.r.girdwood@linux.intel.com>, Jie Yang <yang.jie@linux.intel.com>, Mark Brown <broonie@kernel.org>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-efi@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-acpi@vger.kernel.org, alsa-devel@alsa-project.org

Explicitly include asm/realmode.h, which is needed to handle a real mode
trampoline quirk in efi_free_boot_services(), instead of picking it up
by way of linux/acpi.h.  acpi.h will soon stop including realmode.h so
that changing realmode.h doesn't require a full kernel rebuild.

Fixes: 5bc653b731821 ("x86/efi: Allocate a trampoline if needed in efi_free_boot_services()")
Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>
---
 arch/x86/platform/efi/quirks.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/x86/platform/efi/quirks.c b/arch/x86/platform/efi/quirks.c
index 3b9fd679cea9..f9ef5c5346ca 100644
--- a/arch/x86/platform/efi/quirks.c
+++ b/arch/x86/platform/efi/quirks.c
@@ -16,6 +16,7 @@
 #include <asm/efi.h>
 #include <asm/uv/uv.h>
 #include <asm/cpu_device_id.h>
+#include <asm/realmode.h>
 #include <asm/reboot.h>
 
 #define EFI_MIN_RESERVE 5120
-- 
2.24.0
