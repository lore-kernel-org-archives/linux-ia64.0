From: Kees Cook <keescook@chromium.org>
Date: Sat, 08 Mar 2014 01:00:25 +0000
Subject: [PATCH v2 2/2] kallsyms: handle special absolute symbols
Message-Id: <1394240425-11647-3-git-send-email-keescook@chromium.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1394240425-11647-1-git-send-email-keescook@chromium.org>
In-Reply-To: <1394240425-11647-1-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Honig <ahonig@google.com>, Michal Marek <mmarek@suse.cz>, "x86@kernel.org" <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, keescook@chromium.org, linux-kernel@vger.kernel.org

This forces the entire per_cpu range to be reported as absolute
without losing their linker symbol types, when the per_cpu area is
0-based. Without this, the variables are incorrectly shown as relocated
under kASLR on x86_64.

Several kallsyms output in different boot states for comparison of
various symbols:

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
$ egrep ' (gdt_|_(stext|_per_cpu_))' /root/kallsyms.kaslr2
000000000d400000 D __per_cpu_start
000000000d404000 D gdt_page
000000000d414280 D __per_cpu_end
ffffffff8e4001c8 T _stext
ffffffff8f2e53c0 D __per_cpu_offset
$ egrep ' (gdt_|_(stext|_per_cpu_))' /root/kallsyms.kaslr-fixed
0000000000000000 D __per_cpu_start
0000000000004000 D gdt_page
0000000000014280 D __per_cpu_end
ffffffffadc001c8 T _stext
ffffffffaeae53c0 D __per_cpu_offset

Signed-off-by: Kees Cook <keescook@chromium.org>
---
v2:
 - only force absolute when per_cpu starts at 0.
---
 scripts/kallsyms.c |   20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/scripts/kallsyms.c b/scripts/kallsyms.c
index 08f30ac5b07d..d3f93b8eb277 100644
--- a/scripts/kallsyms.c
+++ b/scripts/kallsyms.c
@@ -34,6 +34,7 @@ struct sym_entry {
 	unsigned int len;
 	unsigned int start_pos;
 	unsigned char *sym;
+	int force_absolute;
 };
 
 struct addr_range {
@@ -51,6 +52,14 @@ static struct addr_range text_ranges[] = {
 #define text_range_text     (&text_ranges[0])
 #define text_range_inittext (&text_ranges[1])
 
+/*
+ * Variables in these ranges, when the start is 0 based, will be forced to
+ * be handled as absolute addresses.
+ */
+static struct addr_range abs_ranges[] = {
+	{ "__per_cpu_start",	"__per_cpu_end", -1ULL, 0 },
+};
+
 static struct sym_entry *table;
 static unsigned int table_size, table_cnt;
 static int all_symbols = 0;
@@ -165,6 +174,10 @@ static int read_symbol(FILE *in, struct sym_entry *s)
 	}
 	strcpy((char *)s->sym + 1, str);
 	s->sym[0] = stype;
+	s->force_absolute = 0;
+
+	/* Check if we've found special absolute symbol range. */
+	check_symbol_range(sym, s->addr, abs_ranges, ARRAY_SIZE(abs_ranges));
 
 	return 0;
 }
@@ -211,6 +224,11 @@ static int symbol_valid(struct sym_entry *s)
 	if (s->addr < kernel_start_addr)
 		return 0;
 
+	/* Force zero-based range special symbols into being absolute. */
+	i = symbol_in_range(s, abs_ranges, ARRAY_SIZE(abs_ranges));
+	if (i >= 0 && abs_ranges[i].start = 0)
+		s->force_absolute = 1;
+
 	/* skip prefix char */
 	if (symbol_prefix_char && *(s->sym + 1) = symbol_prefix_char)
 		offset++;
@@ -307,7 +325,7 @@ static int expand_symbol(unsigned char *data, int len, char *result)
 
 static int symbol_absolute(struct sym_entry *s)
 {
-	return toupper(s->sym[0]) = 'A';
+	return s->force_absolute || toupper(s->sym[0]) = 'A';
 }
 
 static void write_src(void)
-- 
1.7.9.5

