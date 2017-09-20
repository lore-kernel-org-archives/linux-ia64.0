From: Joe Perches <joe@perches.com>
Date: Wed, 20 Sep 2017 17:38:58 +0000
Subject: Re: [RFC][PATCH v2 7/7] checkpatch: add pF/pf deprecation warning
Message-Id: <1505929138.12311.5.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170920162910.32053-1-sergey.senozhatsky@gmail.com>
         <20170920162910.32053-8-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170920162910.32053-8-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>
Cc: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@canonical.com>

On Thu, 2017-09-21 at 01:29 +0900, Sergey Senozhatsky wrote:
> We deprecated '%pF/%pf' printk specifiers, since '%pS/%ps' is now smart
> enough to handle function pointer dereference on platforms where such
> dereference is required.
>=20
> checkpatch warning example:
>=20
> WARNING: Use '%pS/%ps' instead. This pointer extension was deprecated: '%=
pF'

If this series is accepted,  I think this message
is unclear and would prefer something like:
---
scripts/checkpatch.pl | 11 +++++++++--
=A01 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index dd2c262aebbf..71f3273d5913 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5762,18 +5762,25 @@ sub process {
=A0		=A0=A0=A0=A0=A0=A0=A0=A0for (my $count =3D $linenr; $count <=3D $lc; $=
count++) {
=A0				my $fmt =3D get_quoted_string($lines[$count - 1], raw_line($count, 0=
));
=A0				$fmt =3D~ s/%%//g;
-				if ($fmt =3D~ /(\%[\*\d\.]*p(?![\WFfSsBKRraEhMmIiUDdgVCbGNO]).)/) {
+				if ($fmt =3D~ /(\%[\*\d\.]*p(?![\WSsBKRraEhMmIiUDdgVCbGNO]).)/) {
=A0					$bad_extension =3D $1;
=A0					last;
=A0				}
=A0			}
=A0			if ($bad_extension ne "") {
=A0				my $stat_real =3D raw_line($linenr, 0);
+				my $ext_type =3D "Invalid";
+				my $use =3D "";
=A0				for (my $count =3D $linenr + 1; $count <=3D $lc; $count++) {
=A0					$stat_real =3D $stat_real . "\n" . raw_line($count, 0);
=A0				}
+				if ($bad_extension =3D~ /p[Ff]/i) {
+					$ext_type =3D "Deprecated";
+					$use =3D " - use %pS instead";
+					$use =3D~ s/pS/ps/ if ($bad_extension =3D~ /pf/);
+				}
=A0				WARN("VSPRINTF_POINTER_EXTENSION",
-				=A0=A0=A0=A0=A0"Invalid vsprintf pointer extension '$bad_extension'\n"=
 . "$here\n$stat_real\n");
+				=A0=A0=A0=A0=A0"$ext_type vsprintf pointer extension '$bad_extension'$=
use\n" . "$here\n$stat_real\n");
=A0			}
=A0		}
=A0
