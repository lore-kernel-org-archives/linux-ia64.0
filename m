From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 03 May 2023 08:09:39 +0000
Subject: Re: [PATCH v3 4/6] fbdev: Include <linux/io.h> via <asm/fb.h>
Message-Id: <CAMuHMdW8Sm7sBu47XQ1xygn6fzq2FzQeiuK0ncMVGHan-_k4Ow@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230502130223.14719-1-tzimmermann@suse.de> <20230502130223.14719-5-tzimmermann@suse.de>
 <20230502195429.GA319489@ravnborg.org> <563673c0-799d-e353-974c-91b1ab881a22@suse.de>
 <87354dyj9i.fsf@minerva.mail-host-address-is-not-set>
In-Reply-To: <87354dyj9i.fsf@minerva.mail-host-address-is-not-set>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Javier Martinez Canillas <javierm@redhat.com>
Cc: Thomas Zimmermann <tzimmermann@suse.de>, Sam Ravnborg <sam@ravnborg.org>, linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, arnd@arndb.de, deller@gmx.de, chenhuacai@kernel.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, linux-m68k@lists.linux-m68k.org, linux-parisc@vger.kernel.org, vgupta@kernel.org, sparclinux@vger.kernel.org, kernel@xen0n.name, linux-snps-arc@lists.infradead.org, davem@davemloft.net, linux-arm-kernel@lists.infradead.org

On Wed, May 3, 2023 at 9:19=E2=80=AFAM Javier Martinez Canillas
<javierm@redhat.com> wrote:
> Thomas Zimmermann <tzimmermann@suse.de> writes:
> > Am 02.05.23 um 21:54 schrieb Sam Ravnborg:
> >> On Tue, May 02, 2023 at 03:02:21PM +0200, Thomas Zimmermann wrote:
>
> [...]
>
> >>>   #include <linux/console.h> /* Why should fb driver call console fun=
ctions? because console_lock() */
> >>>   #include <video/vga.h>
> >>>
> >>> +#include <asm/fb.h>
> >>
> >> When we have a header like linux/fb.h - it is my understanding that it=
 is
> >> preferred to include that file, and not the asm/fb.h variant.
> >>
> >> This is assuming the linux/fb.h contains the generic stuff, and includ=
es
> >> asm/fb.h for the architecture specific parts.
> >>
> >> So drivers will include linux/fb.h and then they automatically get the
> >> architecture specific parts from asm/fb.h.
> >>
> >> In other words, drivers are not supposed to include asm/fb.h, if
> >> linux.fb.h exists - and linux/fb.h shall include the asm/fb.h.
> >>
> >> If the above holds true, then it is wrong and not needed to add asm/fb=
.h
> >> as seen above.
> >>
> >>
> >> There are countless examples where the above are not followed,
> >> but to my best understanding the above it the preferred way to do it.
> >
> > Where did youher this? I only know about this in the case of asm/io.h
> > vs. linux/io.h.
> >
>
> I understand that's the case too. I believe even checkpatch.pl complains
> about it? (not that the script always get right, but just as an example).

One more to chime in: in general, drivers should only include <linux/foo.h>.
Including <asm/foo.h> directly is the exception.

Gr{oetje,eeting}s,

                        Geert

--=20
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
