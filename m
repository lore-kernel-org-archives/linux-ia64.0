From: Masahiro Yamada <masahiroy@kernel.org>
Date: Mon, 26 Sep 2022 20:36:23 +0000
Subject: [PATCH v2 5/7] modpost: squash report_sec_mismatch() and remove enum mismatch
Message-Id: <20220926203625.1117261-6-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220926203625.1117261-1-masahiroy@kernel.org>
In-Reply-To: <20220926203625.1117261-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, Nicolas Pitre <npitre@baylibre.com>, Masahiro Yamada <masahiroy@kernel.org>, Michal Marek <michal.lkml@markovi.net>, Nick Desaulniers <ndesaulniers@google.com>

Now report_sec_mismatch() prints the same warning message for all
possible cases. (fatal() is just a sanity check for unreachable code.)

Squash it into default_mismatch_handler().

enum mismatch is no longer used. Remove it as well.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

Changes in v2:
  - New patch

 scripts/mod/modpost.c | 61 +++----------------------------------------
 1 file changed, 4 insertions(+), 57 deletions(-)

diff --git a/scripts/mod/modpost.c b/scripts/mod/modpost.c
index 29f30558a398..90733664a602 100644
--- a/scripts/mod/modpost.c
+++ b/scripts/mod/modpost.c
@@ -847,18 +847,6 @@ static const char *const linker_symbols[]  	{ "__init_begin", "_sinittext", "_einittext", NULL };
 static const char *const optim_symbols[] = { "*.constprop.*", NULL };
 
-enum mismatch {
-	TEXT_TO_ANY_INIT,
-	DATA_TO_ANY_INIT,
-	TEXT_TO_ANY_EXIT,
-	DATA_TO_ANY_EXIT,
-	XXXINIT_TO_SOME_INIT,
-	XXXEXIT_TO_SOME_EXIT,
-	ANY_INIT_TO_ANY_EXIT,
-	ANY_EXIT_TO_ANY_INIT,
-	EXTABLE_TO_NON_TEXT,
-};
-
 /**
  * Describe how to match sections on different criteria:
  *
@@ -880,7 +868,6 @@ struct sectioncheck {
 	const char *fromsec[20];
 	const char *bad_tosec[20];
 	const char *good_tosec[20];
-	enum mismatch mismatch;
 	void (*handler)(const char *modname, struct elf_info *elf,
 			const struct sectioncheck* const mismatch,
 			Elf_Rela *r, Elf_Sym *sym, const char *fromsec);
@@ -899,56 +886,46 @@ static const struct sectioncheck sectioncheck[] = {
 {
 	.fromsec = { TEXT_SECTIONS, NULL },
 	.bad_tosec = { ALL_INIT_SECTIONS, NULL },
-	.mismatch = TEXT_TO_ANY_INIT,
 },
 {
 	.fromsec = { DATA_SECTIONS, NULL },
 	.bad_tosec = { ALL_XXXINIT_SECTIONS, NULL },
-	.mismatch = DATA_TO_ANY_INIT,
 },
 {
 	.fromsec = { DATA_SECTIONS, NULL },
 	.bad_tosec = { INIT_SECTIONS, NULL },
-	.mismatch = DATA_TO_ANY_INIT,
 },
 {
 	.fromsec = { TEXT_SECTIONS, NULL },
 	.bad_tosec = { ALL_EXIT_SECTIONS, NULL },
-	.mismatch = TEXT_TO_ANY_EXIT,
 },
 {
 	.fromsec = { DATA_SECTIONS, NULL },
 	.bad_tosec = { ALL_EXIT_SECTIONS, NULL },
-	.mismatch = DATA_TO_ANY_EXIT,
 },
 /* Do not reference init code/data from meminit code/data */
 {
 	.fromsec = { ALL_XXXINIT_SECTIONS, NULL },
 	.bad_tosec = { INIT_SECTIONS, NULL },
-	.mismatch = XXXINIT_TO_SOME_INIT,
 },
 /* Do not reference exit code/data from memexit code/data */
 {
 	.fromsec = { ALL_XXXEXIT_SECTIONS, NULL },
 	.bad_tosec = { EXIT_SECTIONS, NULL },
-	.mismatch = XXXEXIT_TO_SOME_EXIT,
 },
 /* Do not use exit code/data from init code */
 {
 	.fromsec = { ALL_INIT_SECTIONS, NULL },
 	.bad_tosec = { ALL_EXIT_SECTIONS, NULL },
-	.mismatch = ANY_INIT_TO_ANY_EXIT,
 },
 /* Do not use init code/data from exit code */
 {
 	.fromsec = { ALL_EXIT_SECTIONS, NULL },
 	.bad_tosec = { ALL_INIT_SECTIONS, NULL },
-	.mismatch = ANY_EXIT_TO_ANY_INIT,
 },
 {
 	.fromsec = { ALL_PCI_INIT_SECTIONS, NULL },
 	.bad_tosec = { INIT_SECTIONS, NULL },
-	.mismatch = ANY_INIT_TO_ANY_EXIT,
 },
 {
 	.fromsec = { "__ex_table", NULL },
@@ -957,7 +934,6 @@ static const struct sectioncheck sectioncheck[] = {
 	 */
 	.bad_tosec = { ".altinstr_replacement", NULL },
 	.good_tosec = {ALL_TEXT_SECTIONS , NULL},
-	.mismatch = EXTABLE_TO_NON_TEXT,
 	.handler = extable_mismatch_handler,
 }
 };
@@ -1215,37 +1191,6 @@ static inline void get_pretty_name(int is_func, const char** name, const char**
 	}
 }
 
-/*
- * Print a warning about a section mismatch.
- * Try to find symbols near it so user can find it.
- * Check whitelist before warning - it may be a false positive.
- */
-static void report_sec_mismatch(const char *modname,
-				const struct sectioncheck *mismatch,
-				const char *fromsec,
-				const char *fromsym,
-				const char *tosec, const char *tosym)
-{
-	sec_mismatch_count++;
-
-	switch (mismatch->mismatch) {
-	case TEXT_TO_ANY_INIT:
-	case DATA_TO_ANY_INIT:
-	case TEXT_TO_ANY_EXIT:
-	case DATA_TO_ANY_EXIT:
-	case XXXINIT_TO_SOME_INIT:
-	case XXXEXIT_TO_SOME_EXIT:
-	case ANY_INIT_TO_ANY_EXIT:
-	case ANY_EXIT_TO_ANY_INIT:
-		warn("%s: section mismatch in reference: %s (section: %s) -> %s (section: %s)\n",
-		     modname, fromsym, fromsec, tosym, tosec);
-		break;
-	case EXTABLE_TO_NON_TEXT:
-		fatal("There's a special handler for this mismatch type, we should never get here.\n");
-		break;
-	}
-}
-
 static void default_mismatch_handler(const char *modname, struct elf_info *elf,
 				     const struct sectioncheck* const mismatch,
 				     Elf_Rela *r, Elf_Sym *sym, const char *fromsec)
@@ -1266,8 +1211,10 @@ static void default_mismatch_handler(const char *modname, struct elf_info *elf,
 	/* check whitelist - we may ignore it */
 	if (secref_whitelist(mismatch,
 			     fromsec, fromsym, tosec, tosym)) {
-		report_sec_mismatch(modname, mismatch,
-				    fromsec, fromsym, tosec, tosym);
+		sec_mismatch_count++;
+
+		warn("%s: section mismatch in reference: %s (section: %s) -> %s (section: %s)\n",
+		     modname, fromsym, fromsec, tosym, tosec);
 	}
 }
 
-- 
2.34.1
