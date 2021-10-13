From: Kees Cook <keescook@chromium.org>
Date: Wed, 13 Oct 2021 07:27:19 +0000
Subject: Re: [PATCH v1 05/10] asm-generic: Define 'funct_descr_t' to commonly describe function descriptors
Message-Id: <202110130026.0AB963F82@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1633964380.git.christophe.leroy@csgroup.eu>
 <02224551451ab9c37055499fc621c41246c81125.1633964380.git.christophe.leroy@csgroup.eu>
 <202110130001.11A50456@keescook>
 <cf0e465e-e678-692c-3ca5-fde70ba4fc97@csgroup.eu>
In-Reply-To: <cf0e465e-e678-692c-3ca5-fde70ba4fc97@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 13, 2021 at 09:23:56AM +0200, Christophe Leroy wrote:
>=20
>=20
> Le 13/10/2021 =E0 09:01, Kees Cook a =E9crit=A0:
> > On Mon, Oct 11, 2021 at 05:25:32PM +0200, Christophe Leroy wrote:
> > > We have three architectures using function descriptors, each with its
> > > own name.
> > >=20
> > > Add a common typedef that can be used in generic code.
> > >=20
> > > Also add a stub typedef for architecture without function descriptors,
> >=20
> > nit: funct_descr_t reads weird to me. why not func_desc_t ? Either way:
>=20
> func_desc_t already exists in powerpc. I have a patch to remove it as it =
is
> redundant with struct ppc64_opd_entry, but I didnt' want to include it in
> this series.
>=20
> But after all I can add it in this series, I'll add it in v2.

Ah-ha! That works for me. :) Thanks!

-Kees

--=20
Kees Cook
