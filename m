From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Tue, 19 Nov 2019 12:38:51 +0000
Subject: Re: [PATCH] x86/platform/intel/quark: Explicitly include linux/io.h for virt_to_phys()
Message-Id: <CAHp75VeYXonBT9eYhqvS9qyOogdaCu8ERv0XMg12hrVBYt6hnw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191119002121.4107-1-sean.j.christopherson@intel.com>
 <20191119111012.GA109842@gmail.com> <20191119120655.GA31444@gmail.com>
In-Reply-To: <20191119120655.GA31444@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Sean Christopherson <sean.j.christopherson@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Steven Rostedt <rostedt@goodmis.org>, Ard Biesheuvel <ardb@kernel.org>, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, Nadav Amit <namit@vmware.com>, "VMware, Inc." <pv-drivers@vmware.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hans de Goede <hdegoede@redhat.com>, Cezary Rojewski <cezary.rojewski@intel.com>, Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>, Liam Girdwood <liam.r.girdwood@linux.intel.com>, Jie Yang <yang.jie@linux.intel.com>, Mark Brown <broonie@kernel.org>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, linux-efi <linux-efi@vger.kernel.org>, Platform Driver <platform-driver-x86@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, ALSA Development Mailing List <alsa-devel@alsa-project.org>

On Tue, Nov 19, 2019 at 2:07 PM Ingo Molnar <mingo@kernel.org> wrote:
>
>
> * Ingo Molnar <mingo@kernel.org> wrote:
>
> > I've applied them to tip:WIP.core/headers as a work-in-progress tree,
> > and I'm testing them on randconfigs to make sure there's no broken
> > dependencies. I'll wait for the ACPI acks.
>
> One more fix was needed, for the intel-quark driver that is only built on
> 32-bit configs:
>
> =========>
> From: Ingo Molnar <mingo@kernel.org>
> Date: Tue, 19 Nov 2019 12:51:56 +0100
> Subject: [PATCH] x86/platform/intel/quark: Explicitly include linux/io.h for virt_to_phys()
>
> Similarly to the previous patches by Sean Christopherson:
>
>  "Through a labyrinthian sequence of includes, usage of virt_to_phys() is
>   dependent on the include of asm/io.h in x86's asm/realmode.h, which is
>   included in x86's asm/acpi.h and thus by linux/acpi.h.  Explicitly
>   include linux/io.h to break the dependency on realmode.h so that a
>   future patch can remove the realmode.h include from acpi.h without
>   breaking the build."
>

LGTM,
Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>

> Cc: linux-kernel@vger.kernel.org
> Cc: Sean Christopherson <sean.j.christopherson@intel.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>  arch/x86/platform/intel-quark/imr.c          | 2 ++
>  arch/x86/platform/intel-quark/imr_selftest.c | 2 ++
>  2 files changed, 4 insertions(+)
>
> diff --git a/arch/x86/platform/intel-quark/imr.c b/arch/x86/platform/intel-quark/imr.c
> index 6dd25dc5f027..e9d97d52475e 100644
> --- a/arch/x86/platform/intel-quark/imr.c
> +++ b/arch/x86/platform/intel-quark/imr.c
> @@ -29,6 +29,8 @@
>  #include <asm/cpu_device_id.h>
>  #include <asm/imr.h>
>  #include <asm/iosf_mbi.h>
> +#include <asm/io.h>

A nit: perhaps put it after imr.h.

> +
>  #include <linux/debugfs.h>
>  #include <linux/init.h>
>  #include <linux/mm.h>
> diff --git a/arch/x86/platform/intel-quark/imr_selftest.c b/arch/x86/platform/intel-quark/imr_selftest.c
> index 42f879b75f9b..4307830e1b6f 100644
> --- a/arch/x86/platform/intel-quark/imr_selftest.c
> +++ b/arch/x86/platform/intel-quark/imr_selftest.c
> @@ -14,6 +14,8 @@
>  #include <asm-generic/sections.h>
>  #include <asm/cpu_device_id.h>
>  #include <asm/imr.h>
> +#include <asm/io.h>
> +
>  #include <linux/init.h>
>  #include <linux/mm.h>
>  #include <linux/types.h>
>


-- 
With Best Regards,
Andy Shevchenko
