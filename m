From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 30 Jun 2004 19:33:45 +0000
Subject: Re: Linker bug in Debian unstable?
Message-Id: <20040630193345.GA26483@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040630192143.GE30334@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040630192143.GE30334@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, Jun 30, 2004 at 08:21:43PM +0100, Matthew Wilcox wrote:
>=20
> GNU ld version 2.14.90.0.7 20031029 Debian GNU/Linux
>=20
> Here's the snippet of code (from libgnome-2.6.1-5):
>=20
> GnomeProgram *
> gnome_program_init (const char *app_id, const char *app_version,
>                     const GnomeModuleInfo *module_info,
>                     int argc, char **argv,
>                     const char *first_property_name, ...)
> {
>     GnomeProgram *program;
>     va_list args;
>=20
>     g_type_init ();
>=20
>     va_start(args, first_property_name);
>     program =3D gnome_program_initv (GNOME_TYPE_PROGRAM,
>                                    app_id, app_version, module_info,
>                                    argc, argv, first_property_name, args);
>     va_end(args);
>=20
>     return program;
> }
>=20
> objdump -dr gnome-program.o gives:
>=20
>     ac40:       1c 00 94 1c 98 11       [MFB]       st8 [r14]=3Dr37
>                         ac42: PCREL21B  g_type_init
>     ac46:       00 00 00 02 00 00                   nop.f 0x0
>     ac4c:       08 00 00 50                         br.call.sptk.many b0=
=AC40 <g
> nome_program_init+0x90>
>=20
> But objdump -dr .libs/libgnome-2.so.0.601.0:
>=20
>    25750:       1c 00 94 1c 98 11       [MFB]       st8 [r14]=3Dr37
>    25756:       00 00 00 02 00 00                   nop.f 0x0
>    2575c:       08 00 00 50                         br.call.sptk.many b0%=
750 <
> gnome_program_init+0x90>
>=20
> The reloc has gone, but presumably it should still be there as g_type_ini=
t()
> is part of glib-2.0.
>=20
> NB: This problem currently prevents mozilla from running.  Probably other
> gnome apps too ...
>=20

Are you talking about

http://sources.redhat.com/ml/binutils/2004-06/msg00295.html


H.J.
