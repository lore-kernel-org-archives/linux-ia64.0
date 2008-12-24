From: Steven Rostedt <srostedt@redhat.com>
Date: Wed, 24 Dec 2008 01:00:24 +0000
Subject: Re: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <1230080424.30177.115.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


On Wed, 2008-12-24 at 08:54 +0800, Shaohua Li wrote:

>=20
> > > +static unsigned char *ftrace_nop_replace(void)
> > > +{
> > > +     return ftrace_nop_code;
> > > +}
> > > +
> > > +/* In IA64, each function will be added below two bundles with -pg o=
ption */
> > > +static unsigned char __attribute__((aligned(8)))
> > > +ftrace_call_code[MCOUNT_INSN_SIZE] =3D {
> > > +     0x02, 0x40, 0x31, 0x10, 0x80, 0x05, /* alloc r40=3Dar.pfs,12,8,=
0 */
> > > +     0xb0, 0x02, 0x00, 0x00, 0x42, 0x40, /* mov r43=3Dr0;; */
> > > +     0x05, 0x00, 0xc4, 0x00,             /* mov r42=B0 */
> > > +     0x11, 0x48, 0x01, 0x02, 0x00, 0x21, /* mov r41=3Dr1 */
> > > +     0x00, 0x00, 0x00, 0x02, 0x00, 0x00, /* nop.i 0x0 */
> >=20
> > If you made your own PLT stub, could you just change the one line to
> > jump to that stub?
> A simple jump to PLT stub doesn't work in IA64, as a lot of registers
> should be saved. I'll do more investigation.

So the registers are different depending on what function is called?
That is, you would have to change more than one of these lines if you
were to change it from calling _mcount to calling ftrace_stub?


>=20
> > > Index: linux/scripts/recordmcount.pl
> > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> > > --- linux.orig/scripts/recordmcount.pl =
       2008-12-23 13:24:59.000000000 +0800
> > > +++ linux/scripts/recordmcount.pl     2008-12-23 13:30:09.000000000 +=
0800
> > > @@ -206,6 +206,13 @@ if ($arch eq "x86_64") {
> > >      $alignment =3D 2;
> > >      $section_type =3D '%progbits';
> > >
> > > +} elsif ($arch eq "ia64") {
> > > +    $mcount_regex =3D "^\\s*([0-9a-fA-F]+):.*\\s_mcount\$";
> > > +    $type =3D "data8";
> > > +
> > > +    if ($is_module eq "0") {
> > > +        $cc .=3D " -mconstant-gp";
> > > +    }
> >=20
> > I wonder if it would be better to pass in CFLAGS and then be able to
> > parse that instead. Then we can find out a lot more about what we are
> > working on.
> CFLAGS seems have a lot of useless flags here.

OK, I was hoping to start making the parameters a bit smaller. But this
is fine.

-- Steve


