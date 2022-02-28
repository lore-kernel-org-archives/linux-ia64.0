From: Kees Cook <keescook@chromium.org>
Date: Mon, 28 Feb 2022 20:41:47 +0000
Subject: Re: regression: Bug 215601 - gcc segv at startup on ia64
Message-Id: <202202281240.8BCFBB47ED@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <202202260344.63C15C3356@keescook>
 <Yhyn9cjDV8XfXLHm@fractal.localdomain>
In-Reply-To: <Yhyn9cjDV8XfXLHm@fractal.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Magnus =?iso-8859-1?Q?Gro=DF?= <magnus.gross@rwth-aachen.de>
Cc: akpm@linux-foundation.org, anthony.yznaga@oracle.com, glaubitz@physik.fu-berlin.de, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, matoro_bugzilla_kernel@matoro.tk, matoro_mailinglist_kernel@matoro.tk, regressions@leemhuis.info, regressions@lists.linux.dev, viro@zeniv.linux.org.uk

On Mon, Feb 28, 2022 at 11:46:13AM +0100, Magnus Gro=DF wrote:
> > When the kernel tries to map these with a combined allocation, it asks
> > for a giant mmap of the file, but the file is, of course, not at all
> > that large, and the mapping is rejected.
>=20
> > So... I'm trying to think about how best to deal with this. If I or
> > anyone else can't think of an elegant solution, I'll send a revert for
> > the offending patch next week.
>=20
> Shouldn't we just be able to patch total_mapping_size() again to instead
> sum up all p_memsz fields, instead of comparing minimum and maximum
> p_vaddr?

I don't think so, and I need to have a "minimal change" to fix this so
it's more obviously correct.

And, apologies, I failed to Cc you on this patch:
https://lore.kernel.org/linux-hardening/20220228194613.1149432-1-keescook@c=
hromium.org/

--=20
Kees Cook
