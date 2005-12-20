From: Andreas Schwab <schwab@suse.de>
Date: Tue, 20 Dec 2005 00:05:03 +0000
Subject: Re: Can somebody with flex/bison experience help with genksyms?
Message-Id: <jelkygljkg.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051219214019.GA25888@lnx-holt.americas.sgi.com>
In-Reply-To: <20051219214019.GA25888@lnx-holt.americas.sgi.com> (Robin Holt's
	message of "Mon, 19 Dec 2005 15:40:19 -0600")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Robin Holt <holt@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, rth@redhat.com, bj0rn@blox.se

Robin Holt <holt@sgi.com> writes:

> The following code fails to generate a crc when run through genksyms.
>
> #include <linux/module.h>
>
> struct nodepda_s {
> 	int	z1, z2;
> }
>
> DEFINE_PER_CPU(struct nodepda_s *, __sn_nodepda);
> EXPORT_PER_CPU_SYMBOL(__sn_nodepda);
>
> While the following works:
>
> #include <linux/module.h>
>
> struct nodepda_s {
>         int     z1, z2;
> }
>
> typedef struct nodepda_s * nodepda_s_p;
>
> DEFINE_PER_CPU(nodepda_s_p, __sn_nodepda);
> EXPORT_PER_CPU_SYMBOL(__sn_nodepda);
>
>
>
> This appears to be due to the way STRUCT_KEYW is handled in parse.y as
> compared to TYPEOF_KEYW.  I know nothing about flex and bison.  I am
> just trolling for anybody willing to help.  I believe the STRUCT_KEYW
> handling would need to consume the *, but am not sure how that is
> conditionally done.

Does this patch help?

--- scripts/genksyms/parse.y.~1~	2005-10-28 02:02:08.000000000 +0200
+++ scripts/genksyms/parse.y	2005-12-20 01:02:46.420239410 +0100
@@ -197,7 +197,7 @@ storage_class_specifier:
 type_specifier:
 	simple_type_specifier
 	| cvar_qualifier
-	| TYPEOF_KEYW '(' decl_specifier_seq ')'
+	| TYPEOF_KEYW '(' decl_specifier_seq m_abstract_declarator ')'
=20
 	/* References to s/u/e's defined elsewhere.  Rearrange things
 	   so that it is easier to expand the definition fully later.  */

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
