From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 21 Jun 2004 22:18:20 +0000
Subject: Re: 2.6.7: kallsyms --all-symbols shows a shift in the symbol addreses
Message-Id: <17974.1087856300@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <40D70AAC.2010006@bull.net>
In-Reply-To: <40D70AAC.2010006@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 21 Jun 2004 09:29:46 -0700, 
"Randy.Dunlap" <rddunlap@osdl.org> wrote:
>On Mon, 21 Jun 2004 18:19:56 +0200 Xavier Bru wrote:
>| There is a problem with the all kallsyms support in 2.6.7 
>| scripts/kallsyms.c.
>| One solution is to exclude from the symbol table the symbols used for 
>| building it (As was provided in KDB patch :-)
>
>Is this the same problem that Keith Owens made a patch for
>against 2.6.7-rc3 on 2004-june-15?
>Subject: [patch 2.6.7-rc3] When two kallsyms passes are not enough
>
>http://marc.theaimsgroup.com/?l=linux-kernel&m8728234402407&w=2

Yes.  That patch has been refined and sent to Andrew Morton, it should
be in 2.6.8-*.  The critical fix is -

Index: 2.6.7-kallsyms/scripts/kallsyms.c
=================================--- 2.6.7-kallsyms.orig/scripts/kallsyms.c	2004-06-20 20:12:08.000000000 +1000
+++ 2.6.7-kallsyms/scripts/kallsyms.c	2004-06-20 23:38:46.000000000 +1000
@@ -72,7 +72,15 @@ symbol_valid(struct sym_entry *s)
 			return 0;
 	}
 
-	if (strstr(s->sym, "_compiled."))
+	/* Exclude symbols which vary between passes.  Passes 1 and 2 must have
+	 * identical symbol lists.  The kallsyms_* symbols below are only added
+	 * after pass 1, they would be included in pass 2 when --all-symbols is
+	 * specified so exclude them to get a stable symbol list.
+	 */
+	if (strstr(s->sym, "_compiled.") ||
+	    strcmp(s->sym, "kallsyms_addresses") = 0 || 
+	    strcmp(s->sym, "kallsyms_num_syms") = 0 || 
+	    strcmp(s->sym, "kallsyms_names") = 0)
 		return 0;
 
 	return 1;

