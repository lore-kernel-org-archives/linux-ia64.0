From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Mon, 25 Jul 2016 15:27:22 +0000
Subject: Re: [RFC v3 13/13] kprobes: port blacklist kprobes to linker table
Message-Id: <20160726002722.5011993d23c2bfeff7a14dee@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
	<1469222687-1600-14-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-14-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@li

On Fri, 22 Jul 2016 14:24:47 -0700
"Luis R. Rodriguez" <mcgrof@kernel.org> wrote:

> kprobe makes use of two sections, the one dealing with the actual
> kprobes was recently ported using the standard section range API.
> The blacklist functionality of kprobes is still using a custom
> section and declaring its custom section using the linker script
> as follows:
> 
> type  Linux-section custom section name  begin                    end
> table .init.data    _kprobe_blacklist    __start_kprobe_blacklist __stop_kprobe_blacklist
> 
> This ports the _kprobe_blacklist custom section to the standard
> Linux linker table API allowing us remove all the custom blacklist
> kprobe section declarations from the linker script.
> 
> This has been tested by trying to register a kprobe on a blacklisted
> symbol (these are declared with NOKPROBE_SYMBOL()), and confirms that
> this fails to work as expected. This was tested with:

This is OK for me, and if you would like to make sure, please use ftrace to probe
 (easier  than making new module) and compare debugfs/blacklist which shows
all blacklisted functions, so if all the function names are same it
must be OK :).

Acked-by: Masami Hiramatsu <mhiramat@kernel.org>


Thank you,

> 
>  # insmod samples/kprobes/kprobe_example.ko symbol="get_kprobe"
> 
> This fails to load as expected with:
> 
> insmod: ERROR: could not insert module samples/kprobes/kprobe_example.ko: Invalid parameters
> 
> v3: this patch was introduced in this series
> 
> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
> ---
>  include/asm-generic/vmlinux.lds.h | 10 ----------
>  include/linux/kprobes.h           |  5 +++--
>  kernel/kprobes.c                  | 11 ++++-------
>  3 files changed, 7 insertions(+), 19 deletions(-)
> 
> diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
> index 1664050e6560..0e4df8c61c18 100644
> --- a/include/asm-generic/vmlinux.lds.h
> +++ b/include/asm-generic/vmlinux.lds.h
> @@ -113,15 +113,6 @@
>  #define BRANCH_PROFILE()
>  #endif
>  
> -#ifdef CONFIG_KPROBES
> -#define KPROBE_BLACKLIST()	. = ALIGN(8);				      \
> -				VMLINUX_SYMBOL(__start_kprobe_blacklist) = .; \
> -				*(_kprobe_blacklist)			      \
> -				VMLINUX_SYMBOL(__stop_kprobe_blacklist) = .;
> -#else
> -#define KPROBE_BLACKLIST()
> -#endif
> -
>  #ifdef CONFIG_EVENT_TRACING
>  #define FTRACE_EVENTS()	. = ALIGN(8);					\
>  			VMLINUX_SYMBOL(__start_ftrace_events) = .;	\
> @@ -519,7 +510,6 @@
>  	*(SECTION_INIT_RODATA)						\
>  	FTRACE_EVENTS()							\
>  	TRACE_SYSCALLS()						\
> -	KPROBE_BLACKLIST()						\
>  	MEM_DISCARD(init.rodata)					\
>  	CLK_OF_TABLES()							\
>  	RESERVEDMEM_OF_TABLES()						\
> diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
> index 3f46b282a3f9..c9bb9caef70c 100644
> --- a/include/linux/kprobes.h
> +++ b/include/linux/kprobes.h
> @@ -43,9 +43,11 @@
>  
>  #ifdef CONFIG_KPROBES
>  #include <linux/ranges.h>
> +#include <linux/tables.h>
>  #include <asm/kprobes.h>
>  
>  DECLARE_SECTION_RANGE(kprobes);
> +DECLARE_LINKTABLE(unsigned long, _kprobe_blacklist);
>  
>  /* kprobe_status settings */
>  #define KPROBE_HIT_ACTIVE	0x00000001
> @@ -490,8 +492,7 @@ static inline int enable_jprobe(struct jprobe *jp)
>   * by using this macro.
>   */
>  #define __NOKPROBE_SYMBOL(fname)			\
> -static unsigned long __used				\
> -	__attribute__((section("_kprobe_blacklist")))	\
> +static LINKTABLE_INIT_DATA(_kprobe_blacklist, all)		\
>  	_kbl_addr_##fname = (unsigned long)fname;
>  #define NOKPROBE_SYMBOL(fname)	__NOKPROBE_SYMBOL(fname)
>  #else
> diff --git a/kernel/kprobes.c b/kernel/kprobes.c
> index 387605682622..4801aa3b4adf 100644
> --- a/kernel/kprobes.c
> +++ b/kernel/kprobes.c
> @@ -2053,14 +2053,13 @@ NOKPROBE_SYMBOL(dump_kprobe);
>   * since a kprobe need not necessarily be at the beginning
>   * of a function.
>   */
> -static int __init populate_kprobe_blacklist(unsigned long *start,
> -					     unsigned long *end)
> +static int __init populate_kprobe_blacklist(void)
>  {
>  	unsigned long *iter;
>  	struct kprobe_blacklist_entry *ent;
>  	unsigned long entry, offset = 0, size = 0;
>  
> -	for (iter = start; iter < end; iter++) {
> +	LINKTABLE_FOR_EACH(iter, _kprobe_blacklist) {
>  		entry = arch_deref_entry_point((void *)*iter);
>  
>  		if (!kernel_text_address(entry) ||
> @@ -2125,8 +2124,7 @@ static struct notifier_block kprobe_module_nb = {
>  };
>  
>  /* Markers of _kprobe_blacklist section */
> -extern unsigned long __start_kprobe_blacklist[];
> -extern unsigned long __stop_kprobe_blacklist[];
> +DEFINE_LINKTABLE_INIT_DATA(unsigned long, _kprobe_blacklist);
>  
>  /* Actual kprobes section range */
>  DEFINE_SECTION_RANGE(kprobes, SECTION_TEXT);
> @@ -2143,8 +2141,7 @@ static int __init init_kprobes(void)
>  		raw_spin_lock_init(&(kretprobe_table_locks[i].lock));
>  	}
>  
> -	err = populate_kprobe_blacklist(__start_kprobe_blacklist,
> -					__stop_kprobe_blacklist);
> +	err = populate_kprobe_blacklist();
>  	if (err) {
>  		pr_err("kprobes: failed to populate blacklist: %d\n", err);
>  		pr_err("Please take care of using kprobes.\n");
> -- 
> 2.8.4
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
