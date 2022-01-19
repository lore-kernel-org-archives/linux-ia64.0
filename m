From: Kees Cook <keescook@chromium.org>
Date: Wed, 19 Jan 2022 21:58:36 +0000
Subject: Re: [PATCH v3 11/12] lkdtm: Fix execute_[user]_location()
Message-Id: <202201191359.5E67E74A@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1634457599.git.christophe.leroy@csgroup.eu>
 <d4688c2af08dda706d3b6786ae5ec5a74e6171f1.1634457599.git.christophe.leroy@csgroup.eu>
 <e7793192-6879-490d-1f37-3d6d6908a121@csgroup.eu>
 <c635dff6-2bca-3486-014f-12ae00bd1777@csgroup.eu>
In-Reply-To: <c635dff6-2bca-3486-014f-12ae00bd1777@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christophe Leroy <christophe.leroy@csgroup.eu>
Cc: Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Paul Mackerras <paulus@samba.org>, Arnd Bergmann <arnd@arndb.de>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Jan 19, 2022 at 08:28:54PM +0100, Christophe Leroy wrote:
> Hi Kees,
>=20
>=20
> Le 17/12/2021 =E0 12:49, Christophe Leroy a =E9crit=A0:
> > Hi Kees,
> >=20
> > Le 17/10/2021 =E0 14:38, Christophe Leroy a =E9crit=A0:
> > > execute_location() and execute_user_location() intent
> > > to copy do_nothing() text and execute it at a new location.
> > > However, at the time being it doesn't copy do_nothing() function
> > > but do_nothing() function descriptor which still points to the
> > > original text. So at the end it still executes do_nothing() at
> > > its original location allthough using a copied function descriptor.
> > >=20
> > > So, fix that by really copying do_nothing() text and build a new
> > > function descriptor by copying do_nothing() function descriptor and
> > > updating the target address with the new location.
> > >=20
> > > Also fix the displayed addresses by dereferencing do_nothing()
> > > function descriptor.
> > >=20
> > > Signed-off-by: Christophe Leroy <christophe.leroy@csgroup.eu>
> >=20
> > Do you have any comment to this patch and to patch 12 ?
> >=20
> > If not, is it ok to get your acked-by ?
>=20
> Any feedback please, even if it's to say no feedback ?

Hi! Thanks for the ping; I haven't had time yet to look at this, but
with -rc1 coming, I should be able to task-switch back to LKDTM for the
dev cycle and I can give some feedback.

-Kees

>=20
> Many thanks,
> Christophe
>=20
> >=20
> > Thanks
> > Christophe
> >=20
> > > ---
> > > =A0 drivers/misc/lkdtm/perms.c | 37 ++++++++++++++++++++++++++++-----=
----
> > > =A0 1 file changed, 28 insertions(+), 9 deletions(-)
> > >=20
> > > diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
> > > index 035fcca441f0..1cf24c4a79e9 100644
> > > --- a/drivers/misc/lkdtm/perms.c
> > > +++ b/drivers/misc/lkdtm/perms.c
> > > @@ -44,19 +44,34 @@ static noinline void do_overwritten(void)
> > > =A0=A0=A0=A0=A0 return;
> > > =A0 }
> > > +static void *setup_function_descriptor(func_desc_t *fdesc, void *dst)
> > > +{
> > > +=A0=A0=A0 if (!have_function_descriptors())
> > > +=A0=A0=A0=A0=A0=A0=A0 return dst;
> > > +
> > > +=A0=A0=A0 memcpy(fdesc, do_nothing, sizeof(*fdesc));
> > > +=A0=A0=A0 fdesc->addr =3D (unsigned long)dst;
> > > +=A0=A0=A0 barrier();
> > > +
> > > +=A0=A0=A0 return fdesc;
> > > +}
> > > +
> > > =A0 static noinline void execute_location(void *dst, bool write)
> > > =A0 {
> > > -=A0=A0=A0 void (*func)(void) =3D dst;
> > > +=A0=A0=A0 void (*func)(void);
> > > +=A0=A0=A0 func_desc_t fdesc;
> > > +=A0=A0=A0 void *do_nothing_text =3D dereference_function_descriptor(=
do_nothing);
> > > -=A0=A0=A0 pr_info("attempting ok execution at %px\n", do_nothing);
> > > +=A0=A0=A0 pr_info("attempting ok execution at %px\n", do_nothing_tex=
t);
> > > =A0=A0=A0=A0=A0 do_nothing();
> > > =A0=A0=A0=A0=A0 if (write =3D CODE_WRITE) {
> > > -=A0=A0=A0=A0=A0=A0=A0 memcpy(dst, do_nothing, EXEC_SIZE);
> > > +=A0=A0=A0=A0=A0=A0=A0 memcpy(dst, do_nothing_text, EXEC_SIZE);
> > > =A0=A0=A0=A0=A0=A0=A0=A0=A0 flush_icache_range((unsigned long)dst,
> > > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 (unsigne=
d long)dst + EXEC_SIZE);
> > > =A0=A0=A0=A0=A0 }
> > > -=A0=A0=A0 pr_info("attempting bad execution at %px\n", func);
> > > +=A0=A0=A0 pr_info("attempting bad execution at %px\n", dst);
> > > +=A0=A0=A0 func =3D setup_function_descriptor(&fdesc, dst);
> > > =A0=A0=A0=A0=A0 func();
> > > =A0=A0=A0=A0=A0 pr_err("FAIL: func returned\n");
> > > =A0 }
> > > @@ -66,16 +81,19 @@ static void execute_user_location(void *dst)
> > > =A0=A0=A0=A0=A0 int copied;
> > > =A0=A0=A0=A0=A0 /* Intentionally crossing kernel/user memory boundary=
. */
> > > -=A0=A0=A0 void (*func)(void) =3D dst;
> > > +=A0=A0=A0 void (*func)(void);
> > > +=A0=A0=A0 func_desc_t fdesc;
> > > +=A0=A0=A0 void *do_nothing_text =3D dereference_function_descriptor(=
do_nothing);
> > > -=A0=A0=A0 pr_info("attempting ok execution at %px\n", do_nothing);
> > > +=A0=A0=A0 pr_info("attempting ok execution at %px\n", do_nothing_tex=
t);
> > > =A0=A0=A0=A0=A0 do_nothing();
> > > -=A0=A0=A0 copied =3D access_process_vm(current, (unsigned long)dst, =
do_nothing,
> > > +=A0=A0=A0 copied =3D access_process_vm(current, (unsigned long)dst,
> > > do_nothing_text,
> > > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 EXEC_SIZ=
E, FOLL_WRITE);
> > > =A0=A0=A0=A0=A0 if (copied < EXEC_SIZE)
> > > =A0=A0=A0=A0=A0=A0=A0=A0=A0 return;
> > > -=A0=A0=A0 pr_info("attempting bad execution at %px\n", func);
> > > +=A0=A0=A0 pr_info("attempting bad execution at %px\n", dst);
> > > +=A0=A0=A0 func =3D setup_function_descriptor(&fdesc, dst);
> > > =A0=A0=A0=A0=A0 func();
> > > =A0=A0=A0=A0=A0 pr_err("FAIL: func returned\n");
> > > =A0 }
> > > @@ -153,7 +171,8 @@ void lkdtm_EXEC_VMALLOC(void)
> > > =A0 void lkdtm_EXEC_RODATA(void)
> > > =A0 {
> > > -=A0=A0=A0 execute_location(lkdtm_rodata_do_nothing, CODE_AS_IS);
> > > +    execute_location(dereference_function_descriptor(lkdtm_rodata_do=
_nothing),
> > >=20
> > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 CODE_AS_IS);
> > > =A0 }
> > > =A0 void lkdtm_EXEC_USERSPACE(void)
> > >=20

--=20
Kees Cook
