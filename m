From: Matthew Wilcox <willy@debian.org>
Date: Wed, 30 Jun 2004 19:21:43 +0000
Subject: Linker bug in Debian unstable?
Message-Id: <20040630192143.GE30334@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


GNU ld version 2.14.90.0.7 20031029 Debian GNU/Linux

Here's the snippet of code (from libgnome-2.6.1-5):

GnomeProgram *
gnome_program_init (const char *app_id, const char *app_version,
                    const GnomeModuleInfo *module_info,
                    int argc, char **argv,
                    const char *first_property_name, ...)
{
    GnomeProgram *program;
    va_list args;

    g_type_init ();

    va_start(args, first_property_name);
    program =3D gnome_program_initv (GNOME_TYPE_PROGRAM,
                                   app_id, app_version, module_info,
                                   argc, argv, first_property_name, args);
    va_end(args);

    return program;
}

objdump -dr gnome-program.o gives:

    ac40:       1c 00 94 1c 98 11       [MFB]       st8 [r14]=3Dr37
                        ac42: PCREL21B  g_type_init
    ac46:       00 00 00 02 00 00                   nop.f 0x0
    ac4c:       08 00 00 50                         br.call.sptk.many b0=AC=
40 <g
nome_program_init+0x90>

But objdump -dr .libs/libgnome-2.so.0.601.0:

   25750:       1c 00 94 1c 98 11       [MFB]       st8 [r14]=3Dr37
   25756:       00 00 00 02 00 00                   nop.f 0x0
   2575c:       08 00 00 50                         br.call.sptk.many b0%75=
0 <
gnome_program_init+0x90>

The reloc has gone, but presumably it should still be there as g_type_init()
is part of glib-2.0.

NB: This problem currently prevents mozilla from running.  Probably other
gnome apps too ...

--=20
"Next the statesmen will invent cheap lies, putting the blame upon=20
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince=20
himself that the war is just, and will thank God for the better sleep=20
he enjoys after this process of grotesque self-deception." -- Mark Twain
