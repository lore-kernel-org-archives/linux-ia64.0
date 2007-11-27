From: Andreas Schwab <schwab@suse.de>
Date: Tue, 27 Nov 2007 21:24:33 +0000
Subject: Re: [patch 04/14] ia64: Remove the __SMALL_ADDR_AREA attribute for per cpu access
Message-Id: <jeabozs7ou.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071127001407.859743255@sgi.com>
	<20071127001430.083503280@sgi.com> <jehcj83uir.fsf@sykes.suse.de>
	<Pine.LNX.4.64.0711271016500.2310@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0711271016500.2310@schroedinger.engr.sgi.com>
	(Christoph Lameter's message of "Tue\, 27 Nov 2007 10\:17\:14 -0800
	\(PST\)")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

Christoph Lameter <clameter@sgi.com> writes:

> On Tue, 27 Nov 2007, Andreas Schwab wrote:
>
>> Christoph Lameter <clameter@sgi.com> writes:
>>=20
>> > The model(small) attribute is not supported by gcc 4.X.
>>=20
>> Which gcc 4.X are you talking about?
>
> All. Last gcc that supported this was 3.4.

Strange.  Works fine here.

$ arch/ia64/scripts/toolchain-flags gcc objdump readelf
-DHAVE_WORKING_TEXT_ALIGN -DHAVE_MODEL_SMALL_ATTRIBUTE -DHAVE_SERIALIZE_DIR=
ECTIVE
$ gcc --version | head -n 1
gcc (GCC) 4.2.1 (SUSE Linux)
$ grep ia64_handle_model_attribute config/ia64/*.c
config/ia64/ia64.c:static tree ia64_handle_model_attribute (tree *, tree, t=
ree, int, bool *);
config/ia64/ia64.c:  { "model",	       1, 1, true, false, false, ia64_handl=
e_model_attribute },
config/ia64/ia64.c:ia64_handle_model_attribute (tree *node, tree name, tree=
 args,
$ grep small_addr_symbolic_operand config/ia64/*.md
config/ia64/constraints.md:  (match_operand 0 "small_addr_symbolic_operand"=
))
config/ia64/predicates.md:(define_predicate "small_addr_symbolic_operand"=20

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
