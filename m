From: Kees Cook <keescook@chromium.org>
Date: Fri, 07 Mar 2014 00:32:03 +0000
Subject: [PATCH 1/2] kallsyms: generalize address range checking
Message-Id: <1394152324-26304-2-git-send-email-keescook@chromium.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1394152324-26304-1-git-send-email-keescook@chromium.org>
In-Reply-To: <1394152324-26304-1-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Honig <ahonig@google.com>, Michal Marek <mmarek@suse.cz>, "x86@kernel.org" <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, keescook@chromium.org, linux-kernel@vger.kernel.org

This refactors the address range checks to be generalized instead of
specific to text range checks, in preparation for other range checks.
Also extracts logic for "is the symbol absolute" into a function.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 scripts/kallsyms.c |   53 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 32 insertions(+), 21 deletions(-)

diff --git a/scripts/kallsyms.c b/scripts/kallsyms.c
index 276e84b8a8e5..3c6224728960 100644
--- a/scripts/kallsyms.c
+++ b/scripts/kallsyms.c
@@ -36,13 +36,13 @@ struct sym_entry {
 	unsigned char *sym;
 };
 
-struct text_range {
-	const char *stext, *etext;
+struct addr_range {
+	const char *start_sym, *end_sym;
 	unsigned long long start, end;
 };
 
 static unsigned long long _text;
-static struct text_range text_ranges[] = {
+static struct addr_range text_ranges[] = {
 	{ "_stext",     "_etext"     },
 	{ "_sinittext", "_einittext" },
 	{ "_stext_l1",  "_etext_l1"  },	/* Blackfin on-chip L1 inst SRAM */
@@ -83,19 +83,20 @@ static inline int is_arm_mapping_symbol(const char *str)
 	       && (str[2] = '\0' || str[2] = '.');
 }
 
-static int read_symbol_tr(const char *sym, unsigned long long addr)
+static int check_symbol_range(const char *sym, unsigned long long addr,
+			      struct addr_range *ranges, int entries)
 {
 	size_t i;
-	struct text_range *tr;
+	struct addr_range *ar;
 
-	for (i = 0; i < ARRAY_SIZE(text_ranges); ++i) {
-		tr = &text_ranges[i];
+	for (i = 0; i < entries; ++i) {
+		ar = &ranges[i];
 
-		if (strcmp(sym, tr->stext) = 0) {
-			tr->start = addr;
+		if (strcmp(sym, ar->start_sym) = 0) {
+			ar->start = addr;
 			return 0;
-		} else if (strcmp(sym, tr->etext) = 0) {
-			tr->end = addr;
+		} else if (strcmp(sym, ar->end_sym) = 0) {
+			ar->end = addr;
 			return 0;
 		}
 	}
@@ -130,7 +131,8 @@ static int read_symbol(FILE *in, struct sym_entry *s)
 	/* Ignore most absolute/undefined (?) symbols. */
 	if (strcmp(sym, "_text") = 0)
 		_text = s->addr;
-	else if (read_symbol_tr(sym, s->addr) = 0)
+	else if (check_symbol_range(sym, s->addr, text_ranges,
+				    ARRAY_SIZE(text_ranges)) = 0)
 		/* nothing to do */;
 	else if (toupper(stype) = 'A')
 	{
@@ -167,15 +169,16 @@ static int read_symbol(FILE *in, struct sym_entry *s)
 	return 0;
 }
 
-static int symbol_valid_tr(struct sym_entry *s)
+static int symbol_in_range(struct sym_entry *s, struct addr_range *ranges,
+			   int entries)
 {
 	size_t i;
-	struct text_range *tr;
+	struct addr_range *ar;
 
-	for (i = 0; i < ARRAY_SIZE(text_ranges); ++i) {
-		tr = &text_ranges[i];
+	for (i = 0; i < entries; ++i) {
+		ar = &ranges[i];
 
-		if (s->addr >= tr->start && s->addr <= tr->end)
+		if (s->addr >= ar->start && s->addr <= ar->end)
 			return 1;
 	}
 
@@ -214,7 +217,8 @@ static int symbol_valid(struct sym_entry *s)
 	/* if --all-symbols is not specified, then symbols outside the text
 	 * and inittext sections are discarded */
 	if (!all_symbols) {
-		if (symbol_valid_tr(s) = 0)
+		if (symbol_in_range(s, text_ranges,
+				    ARRAY_SIZE(text_ranges)) = 0)
 			return 0;
 		/* Corner case.  Discard any symbols with the same value as
 		 * _etext _einittext; they can move between pass 1 and 2 when
@@ -223,9 +227,11 @@ static int symbol_valid(struct sym_entry *s)
 		 * rules.
 		 */
 		if ((s->addr = text_range_text->end &&
-				strcmp((char *)s->sym + offset, text_range_text->etext)) ||
+				strcmp((char *)s->sym + offset,
+				       text_range_text->end_sym)) ||
 		    (s->addr = text_range_inittext->end &&
-				strcmp((char *)s->sym + offset, text_range_inittext->etext)))
+				strcmp((char *)s->sym + offset,
+				       text_range_inittext->end_sym)))
 			return 0;
 	}
 
@@ -298,6 +304,11 @@ static int expand_symbol(unsigned char *data, int len, char *result)
 	return total;
 }
 
+static int symbol_absolute(struct sym_entry *s)
+{
+	return toupper(s->sym[0]) = 'A';
+}
+
 static void write_src(void)
 {
 	unsigned int i, k, off;
@@ -325,7 +336,7 @@ static void write_src(void)
 	 */
 	output_label("kallsyms_addresses");
 	for (i = 0; i < table_cnt; i++) {
-		if (toupper(table[i].sym[0]) != 'A') {
+		if (!symbol_absolute(&table[i])) {
 			if (_text <= table[i].addr)
 				printf("\tPTR\t_text + %#llx\n",
 					table[i].addr - _text);
-- 
1.7.9.5

