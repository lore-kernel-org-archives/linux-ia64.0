From: Masahiro Yamada <masahiroy@kernel.org>
Date: Mon, 26 Sep 2022 20:36:21 +0000
Subject: [PATCH v2 3/7] modpost: merge sym_update_namespace() into sym_add_exported()
Message-Id: <20220926203625.1117261-4-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220926203625.1117261-1-masahiroy@kernel.org>
In-Reply-To: <20220926203625.1117261-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, Nicolas Pitre <npitre@baylibre.com>, Masahiro Yamada <masahiroy@kernel.org>, Nick Desaulniers <ndesaulniers@google.com>, Michal Marek <michal.lkml@markovi.net>

Pass a set of the name, license, and namespace to sym_add_exported().

sym_update_namespace() is unneeded.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
Reviewed-by: Nick Desaulniers <ndesaulniers@google.com>
---

(no changes since v1)

 scripts/mod/modpost.c | 41 +++++++++--------------------------------
 1 file changed, 9 insertions(+), 32 deletions(-)

diff --git a/scripts/mod/modpost.c b/scripts/mod/modpost.c
index 13fff6e92aef..0bb5bbd176b4 100644
--- a/scripts/mod/modpost.c
+++ b/scripts/mod/modpost.c
@@ -352,26 +352,8 @@ static const char *sec_name(const struct elf_info *info, unsigned int secindex)
 
 #define strstarts(str, prefix) (strncmp(str, prefix, strlen(prefix)) = 0)
 
-static void sym_update_namespace(const char *symname, const char *namespace)
-{
-	struct symbol *s = find_symbol(symname);
-
-	/*
-	 * That symbol should have been created earlier and thus this is
-	 * actually an assertion.
-	 */
-	if (!s) {
-		error("Could not update namespace(%s) for symbol %s\n",
-		      namespace, symname);
-		return;
-	}
-
-	free(s->namespace);
-	s->namespace = namespace[0] ? NOFAIL(strdup(namespace)) : NULL;
-}
-
 static struct symbol *sym_add_exported(const char *name, struct module *mod,
-				       bool gpl_only)
+				       bool gpl_only, const char *namespace)
 {
 	struct symbol *s = find_symbol(name);
 
@@ -384,6 +366,7 @@ static struct symbol *sym_add_exported(const char *name, struct module *mod,
 	s = alloc_symbol(name);
 	s->module = mod;
 	s->is_gpl_only = gpl_only;
+	s->namespace = namespace[0] ? NOFAIL(strdup(namespace)) : NULL;
 	list_add_tail(&s->list, &mod->exported_symbols);
 	hash_add_symbol(s);
 
@@ -657,17 +640,12 @@ static void handle_symbol(struct module *mod, struct elf_info *info,
 		break;
 	default:
 		if (sym->st_shndx = info->export_symbol_sec) {
-			const char *name;
-
-			if (strstarts(symname, "__export_symbol_gpl.")) {
-				name = symname + strlen("__export_symbol_gpl.");
-				sym_add_exported(name, mod, true);
-				sym_update_namespace(name, sym_get_data(info, sym));
-			} else if (strstarts(symname, "__export_symbol.")) {
-				name = symname + strlen("__export_symbol.");
-				sym_add_exported(name, mod, false);
-				sym_update_namespace(name, sym_get_data(info, sym));
-			}
+			if (strstarts(symname, "__export_symbol_gpl."))
+				sym_add_exported(symname + strlen("__export_symbol_gpl."),
+						 mod, true, sym_get_data(info, sym));
+			else if (strstarts(symname, "__export_symbol."))
+				sym_add_exported(symname + strlen("__export_symbol."),
+						 mod, false, sym_get_data(info, sym));
 
 			break;
 		}
@@ -2283,9 +2261,8 @@ static void read_dump(const char *fname)
 			mod = new_module(modname, strlen(modname));
 			mod->from_dump = true;
 		}
-		s = sym_add_exported(symname, mod, gpl_only);
+		s = sym_add_exported(symname, mod, gpl_only, namespace);
 		sym_set_crc(s, crc);
-		sym_update_namespace(symname, namespace);
 	}
 	free(buf);
 	return;
-- 
2.34.1
