From: Andreas Schwab <schwab@suse.de>
Date: Thu, 09 Oct 2003 13:21:54 +0000
Subject: genksyms bug: Warning: "per_cpu__local_per_cpu_offset" [...] has no
Message-Id: <marc-linux-ia64-106570613015660@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I'm getting this warning when building 2.6.0-test[567] for ia64 with
MODVERSIONS enabled.  This is a bug in genksyms, it can't cope with some
arguments of __typeof__.  The following patch will fix that.  Actually the
argument of __typeof__ is an abstract declarator, but the genksyms parser
has no production for that; decl_specifier_seq also matches some invalid
constructs, but I don't think this is a problem in practice, since the
compiler will reject them.

Andreas.

--- linux-2.6.0-test7/scripts/genksyms/parse.y.~1~	2003-10-08 21:24:04.0000=
00000 +0200
+++ linux-2.6.0-test7/scripts/genksyms/parse.y	2003-10-09 15:03:38.00000000=
0 +0200
@@ -197,7 +197,7 @@ storage_class_specifier:
 type_specifier:
 	simple_type_specifier
 	| cvar_qualifier
-	| TYPEOF_KEYW '(' type_specifier ')'
+	| TYPEOF_KEYW '(' decl_specifier_seq ')'
=20
 	/* References to s/u/e's defined elsewhere.  Rearrange things
 	   so that it is easier to expand the definition fully later.  */

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
