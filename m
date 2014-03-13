From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 13 Mar 2014 00:42:10 +0000
Subject: Re: [PATCH v2 2/2] kallsyms: handle special absolute symbols
Message-Id: <87y50fuei5.fsf@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1394240425-11647-1-git-send-email-keescook@chromium.org> <1394240425-11647-3-git-send-email-keescook@chromium.org> <CAGXu5j+QoHH004usCiCfJU6DPQFnQ2gt3P4GDLS7Gx8Tz_gK+A@mail.gmail.com>
In-Reply-To: <CAGXu5j+QoHH004usCiCfJU6DPQFnQ2gt3P4GDLS7Gx8Tz_gK+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Honig <ahonig@google.com>, Michal Marek <mmarek@suse.cz>, "x86@kernel.org" <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>

Kees Cook <keescook@chromium.org> writes:
> On Fri, Mar 7, 2014 at 5:00 PM, Kees Cook <keescook@chromium.org> wrote:
>> This forces the entire per_cpu range to be reported as absolute
>> without losing their linker symbol types, when the per_cpu area is
>> 0-based. Without this, the variables are incorrectly shown as relocated
>> under kASLR on x86_64.
>>
>> Several kallsyms output in different boot states for comparison of
>> various symbols:
>>
>> $ egrep ' (gdt_|_(stext|_per_cpu_))' /root/kallsyms.nokaslr
>> 0000000000000000 D __per_cpu_start
>> 0000000000004000 D gdt_page
>> 0000000000014280 D __per_cpu_end
>> ffffffff810001c8 T _stext
>> ffffffff81ee53c0 D __per_cpu_offset
>> $ egrep ' (gdt_|_(stext|_per_cpu_))' /root/kallsyms.kaslr1
>> 000000001f200000 D __per_cpu_start
>> 000000001f204000 D gdt_page
>> 000000001f214280 D __per_cpu_end
>> ffffffffa02001c8 T _stext
>> ffffffffa10e53c0 D __per_cpu_offset
>> $ egrep ' (gdt_|_(stext|_per_cpu_))' /root/kallsyms.kaslr2
>> 000000000d400000 D __per_cpu_start
>> 000000000d404000 D gdt_page
>> 000000000d414280 D __per_cpu_end
>> ffffffff8e4001c8 T _stext
>> ffffffff8f2e53c0 D __per_cpu_offset
>> $ egrep ' (gdt_|_(stext|_per_cpu_))' /root/kallsyms.kaslr-fixed
>> 0000000000000000 D __per_cpu_start
>> 0000000000004000 D gdt_page
>> 0000000000014280 D __per_cpu_end
>> ffffffffadc001c8 T _stext
>> ffffffffaeae53c0 D __per_cpu_offset
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>> v2:
>>  - only force absolute when per_cpu starts at 0.
>> ---
>>  scripts/kallsyms.c |   20 +++++++++++++++++++-
>>  1 file changed, 19 insertions(+), 1 deletion(-)
>>
>> diff --git a/scripts/kallsyms.c b/scripts/kallsyms.c
>> index 08f30ac5b07d..d3f93b8eb277 100644
>> --- a/scripts/kallsyms.c
>> +++ b/scripts/kallsyms.c
>> @@ -34,6 +34,7 @@ struct sym_entry {
>>         unsigned int len;
>>         unsigned int start_pos;
>>         unsigned char *sym;
>> +       int force_absolute;
>>  };
>>
>>  struct addr_range {
>> @@ -51,6 +52,14 @@ static struct addr_range text_ranges[] = {
>>  #define text_range_text     (&text_ranges[0])
>>  #define text_range_inittext (&text_ranges[1])
>>
>> +/*
>> + * Variables in these ranges, when the start is 0 based, will be forced to
>> + * be handled as absolute addresses.
>> + */
>> +static struct addr_range abs_ranges[] = {
>> +       { "__per_cpu_start",    "__per_cpu_end", -1ULL, 0 },
>> +};
>> +
>>  static struct sym_entry *table;
>>  static unsigned int table_size, table_cnt;
>>  static int all_symbols = 0;
>> @@ -165,6 +174,10 @@ static int read_symbol(FILE *in, struct sym_entry *s)
>>         }
>>         strcpy((char *)s->sym + 1, str);
>>         s->sym[0] = stype;
>> +       s->force_absolute = 0;
>> +
>> +       /* Check if we've found special absolute symbol range. */
>> +       check_symbol_range(sym, s->addr, abs_ranges, ARRAY_SIZE(abs_ranges));
>>
>>         return 0;
>>  }
>> @@ -211,6 +224,11 @@ static int symbol_valid(struct sym_entry *s)
>>         if (s->addr < kernel_start_addr)
>>                 return 0;
>>
>> +       /* Force zero-based range special symbols into being absolute. */
>> +       i = symbol_in_range(s, abs_ranges, ARRAY_SIZE(abs_ranges));
>> +       if (i >= 0 && abs_ranges[i].start = 0)
>> +               s->force_absolute = 1;
>
> Rusty, is this 0-detection workable for you? If so, should you or akpm
> carry this series for 3.15?

Damn, sorry, I wrote this patch and seems like I didn't actually send it
out.  No wonder you didn't respond :)

This applies on top of your first cleanup patch:

kallsyms: fix percpu vars on x86-64 with relocation.

x86-64 has a problem: per-cpu variables are actually represented by
their absolute offsets within the per-cpu area, but the symbols are
not emitted as absolute.  Thus kallsyms naively creates them as offsets
from _text, meaning their values change if the kernel is relocated
(especially noticeable with CONFIG_RANDOMIZE_BASE):

 $ egrep ' (gdt_|_(stext|_per_cpu_))' /root/kallsyms.nokaslr
 0000000000000000 D __per_cpu_start
 0000000000004000 D gdt_page
 0000000000014280 D __per_cpu_end
 ffffffff810001c8 T _stext
 ffffffff81ee53c0 D __per_cpu_offset
 $ egrep ' (gdt_|_(stext|_per_cpu_))' /root/kallsyms.kaslr1
 000000001f200000 D __per_cpu_start
 000000001f204000 D gdt_page
 000000001f214280 D __per_cpu_end
 ffffffffa02001c8 T _stext
 ffffffffa10e53c0 D __per_cpu_offset

Making them absolute symbols is the Right Thing, but requires fixes to
the relocs tool.  So for the moment, we add a --absolute-percpu option
which makes them absolute from a kallsyms perspective:

 $ egrep ' (gdt_|_(stext|_per_cpu_))' /proc/kallsyms # no KASLR
 0000000000000000 A __per_cpu_start
 000000000000a000 A gdt_page
 0000000000013040 A __per_cpu_end
 ffffffff802001c8 T _stext
 ffffffff8099b180 D __per_cpu_offset
 ffffffff809a3000 D __per_cpu_load
 $ egrep ' (gdt_|_(stext|_per_cpu_))' /proc/kallsyms # With KASLR
 0000000000000000 A __per_cpu_start
 000000000000a000 A gdt_page
 0000000000013040 A __per_cpu_end
 ffffffff89c001c8 T _stext
 ffffffff8a39d180 D __per_cpu_offset
 ffffffff8a3a5000 D __per_cpu_load

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/scripts/kallsyms.c b/scripts/kallsyms.c
index 3c6224728960..21013e739773 100644
--- a/scripts/kallsyms.c
+++ b/scripts/kallsyms.c
@@ -51,9 +51,14 @@ static struct addr_range text_ranges[] = {
 #define text_range_text     (&text_ranges[0])
 #define text_range_inittext (&text_ranges[1])
 
+static struct addr_range percpu_range = {
+	"__per_cpu_start", "__per_cpu_end", -1ULL, 0
+};
+
 static struct sym_entry *table;
 static unsigned int table_size, table_cnt;
 static int all_symbols = 0;
+static int absolute_percpu = 0;
 static char symbol_prefix_char = '\0';
 static unsigned long long kernel_start_addr = 0;
 
@@ -166,6 +171,9 @@ static int read_symbol(FILE *in, struct sym_entry *s)
 	strcpy((char *)s->sym + 1, str);
 	s->sym[0] = stype;
 
+	/* Record if we've found __per_cpu_start/end. */
+	check_symbol_range(sym, s->addr, &percpu_range, 1);
+
 	return 0;
 }
 
@@ -656,6 +664,15 @@ static void sort_symbols(void)
 	qsort(table, table_cnt, sizeof(struct sym_entry), compare_symbols);
 }
 
+static void make_percpus_absolute(void)
+{
+	unsigned int i;
+
+	for (i = 0; i < table_cnt; i++)
+		if (symbol_in_range(&table[i], &percpu_range, 1))
+			table[i].sym[0] = 'A';
+}
+
 int main(int argc, char **argv)
 {
 	if (argc >= 2) {
@@ -663,6 +683,8 @@ int main(int argc, char **argv)
 		for (i = 1; i < argc; i++) {
 			if(strcmp(argv[i], "--all-symbols") = 0)
 				all_symbols = 1;
+			else if (strcmp(argv[i], "--absolute-percpu") = 0)
+				absolute_percpu = 1;
 			else if (strncmp(argv[i], "--symbol-prefix=", 16) = 0) {
 				char *p = &argv[i][16];
 				/* skip quote */
@@ -679,6 +701,8 @@ int main(int argc, char **argv)
 		usage();
 
 	read_map(stdin);
+	if (absolute_percpu)
+		make_percpus_absolute();
 	sort_symbols();
 	optimize_token_table();
 	write_src();
diff --git a/scripts/link-vmlinux.sh b/scripts/link-vmlinux.sh
index 2dcb37736d84..86a4fe75f453 100644
--- a/scripts/link-vmlinux.sh
+++ b/scripts/link-vmlinux.sh
@@ -86,6 +86,10 @@ kallsyms()
 		kallsymopt="${kallsymopt} --page-offset=$CONFIG_PAGE_OFFSET"
 	fi
 
+	if [ -n "${CONFIG_X86_64}" ]; then
+		kallsymopt="${kallsymopt} --absolute-percpu"
+	fi
+
 	local aflags="${KBUILD_AFLAGS} ${KBUILD_AFLAGS_KERNEL}               \
 		      ${NOSTDINC_FLAGS} ${LINUXINCLUDE} ${KBUILD_CPPFLAGS}"
 

