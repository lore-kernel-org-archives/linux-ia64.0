From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Mon, 25 Jul 2016 15:19:58 +0000
Subject: Re: [RFC v3 12/13] kprobes: port .kprobes.text to section range
Message-Id: <20160726001958.09b64d73e0bdda461ad1451c@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
	<1469222687-1600-13-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-13-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@li

On Fri, 22 Jul 2016 14:24:46 -0700
"Luis R. Rodriguez" <mcgrof@kernel.org> wrote:

> kprobe makes use of two custom sections, each custom section
> is folded into one of the standard Linux sections types as follows,
> it currently relies on the linker script to fold the custom section
> onto the respective Linux section:
> 
> type  Linux-section custom section name  begin                    end
> table .init.data    _kprobe_blacklist    __start_kprobe_blacklist __stop_kprobe_blacklist
> range .text         .kprobes.text        __kprobes_text_start     __kprobes_text_end
> 
> This ports the .kprobes.text custom section to the standard
> Linux ranges API allowing us remove all the custom kprobe section
> declarations from the linker script.
> 
> Tested with CONFIG_KPROBES_SANITY_TEST, it passes with:
> 
> Kprobe smoke test: started
> Kprobe smoke test: passed successfully
> 
> Then tested CONFIG_SAMPLE_KPROBES on do_fork, and the kprobe bites
> and kicks as expected.
> 
> Also ran ./ftracetest with no issues:
> 
> $ sudo ./ftracetest
> == Ftrace unit tests => [1] Basic trace file check      [PASS]
> [2] Basic test for tracers      [PASS]
> [3] Basic trace clock test      [PASS]
> [4] Basic event tracing check   [PASS]
> [5] event tracing - enable/disable with event level files       [PASS]
> [6] event tracing - restricts events based on pid       [PASS]
> [7] event tracing - enable/disable with subsystem level files   [PASS]
> [8] event tracing - enable/disable with top level files [PASS]
> [9] ftrace - function graph filters with stack tracer   [PASS]
> [10] ftrace - function graph filters    [PASS]
> [11] ftrace - function profiler with function tracing   [PASS]
> [12] Test creation and deletion of trace instances while setting an event[PASS]
> [13] Test creation and deletion of trace instances      [PASS]
> [14] Kprobe dynamic event - adding and removing [PASS]
> [15] Kprobe dynamic event - busy event check    [PASS]
> [16] Kprobe dynamic event with arguments        [PASS]
> [17] Kprobe dynamic event with function tracer  [PASS]
> [18] Kretprobe dynamic event with arguments     [PASS]
> [19] event trigger - test event enable/disable trigger  [PASS]
> [20] event trigger - test trigger filter        [PASS]
> [21] event trigger - test histogram modifiers   [PASS]
> [22] event trigger - test histogram trigger     [PASS]
> [23] event trigger - test multiple histogram triggers   [PASS]
> [24] event trigger - test snapshot-trigger      [PASS]
> [25] event trigger - test stacktrace-trigger    [PASS]
> [26] event trigger - test traceon/off trigger   [PASS]
> 
>  # of passed:  26
>  # of failed:  0
>  # of unresolved:  0
>  # of untested:  0
>  # of unsupported:  0
>  # of xfailed:  0
>  # of undefined(test bug):  0

Looks good to me except for the modpost part.

> 
> diff --git a/scripts/Makefile b/scripts/Makefile
> index 1d80897a9644..77a0cc91628c 100644
> --- a/scripts/Makefile
> +++ b/scripts/Makefile
> @@ -10,6 +10,7 @@
>  # check-lc_ctype: Used in Documentation/DocBook
>  
>  HOST_EXTRACFLAGS += -I$(srctree)/tools/include
> +HOST_EXTRACFLAGS += -U__KERNEL__

This looks a add-hoc hack. If we just need SECTION_RNG(SECTION_TEXT, kprobes)
to convert to section name, can we export the definitions outside of _KERNEL_ ?

Thank you,

>  
>  hostprogs-$(CONFIG_KALLSYMS)     += kallsyms
>  hostprogs-$(CONFIG_LOGO)         += pnmtologo
> diff --git a/scripts/mod/Makefile b/scripts/mod/Makefile
> index 8257ef422c0a..76905d4ac0d0 100644
> --- a/scripts/mod/Makefile
> +++ b/scripts/mod/Makefile
> @@ -1,5 +1,7 @@
>  OBJECT_FILES_NON_STANDARD := y
>  
> +HOST_EXTRACFLAGS += -U__KERNEL__
> +
>  hostprogs-y	:= modpost mk_elfconfig
>  always		:= $(hostprogs-y) empty.o
>  
> diff --git a/scripts/mod/modpost.c b/scripts/mod/modpost.c
> index 48958d3cec9e..12ddced5df84 100644
> --- a/scripts/mod/modpost.c
> +++ b/scripts/mod/modpost.c
> @@ -19,10 +19,16 @@
>  #include <stdbool.h>
>  #include <errno.h>
>  #include "modpost.h"
> +
>  #include "../../include/generated/autoconf.h"
>  #include "../../include/linux/license.h"
>  #include "../../include/linux/export.h"
>  
> +#include "../../include/linux/sections.h"
> +#include "../../include/asm-generic/sections.h"
> +#include "../../include/linux/ranges.h"
> +#include "../../include/asm-generic/ranges.h"
> +
>  /* Are we using CONFIG_MODVERSIONS? */
>  static int modversions = 0;
>  /* Warn about undefined symbols? (do so if we have vmlinux) */
> @@ -888,7 +894,7 @@ static void check_section(const char *modname, struct elf_info *elf,
>  
>  #define DATA_SECTIONS ".data", ".data.rel"
>  #define TEXT_SECTIONS ".text", ".text.unlikely", ".sched.text", \
> -		".kprobes.text"
> +		SECTION_RNG(SECTION_TEXT, kprobes)
>  #define OTHER_TEXT_SECTIONS ".ref.text", ".head.text", ".spinlock.text", \
>  		".fixup", ".entry.text", ".exception.text", ".text.*", \
>  		".coldtext"
> diff --git a/scripts/recordmcount.c b/scripts/recordmcount.c
> index e167592793a7..8381d75235d4 100644
> --- a/scripts/recordmcount.c
> +++ b/scripts/recordmcount.c
> @@ -33,6 +33,11 @@
>  #include <string.h>
>  #include <unistd.h>
>  
> +#include "../../include/linux/sections.h"
> +#include "../../include/asm-generic/sections.h"
> +#include "../../include/linux/ranges.h"
> +#include "../../include/asm-generic/ranges.h"
> +
>  #ifndef EM_METAG
>  /* Remove this when these make it to the standard system elf.h. */
>  #define EM_METAG      174
> @@ -356,7 +361,7 @@ is_mcounted_section_name(char const *const txtname)
>  		strcmp(".sched.text",    txtname) = 0 ||
>  		strcmp(".spinlock.text", txtname) = 0 ||
>  		strcmp(".irqentry.text", txtname) = 0 ||
> -		strcmp(".kprobes.text", txtname) = 0 ||
> +		strcmp(SECTION_RNG(SECTION_TEXT, kprobe), txtname) = 0 ||
>  		strcmp(".text.unlikely", txtname) = 0;
>  }
>  
> diff --git a/scripts/recordmcount.pl b/scripts/recordmcount.pl
> index 96e2486a6fc4..f663a7c5d6ab 100755
> --- a/scripts/recordmcount.pl
> +++ b/scripts/recordmcount.pl
> @@ -134,7 +134,7 @@ my %text_sections = (
>       ".sched.text" => 1,
>       ".spinlock.text" => 1,
>       ".irqentry.text" => 1,
> -     ".kprobes.text" => 1,
> +     ".text.rng.kprobes.any" => 1,
>       ".text.unlikely" => 1,
>  );
>  
> -- 
> 2.8.4
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
