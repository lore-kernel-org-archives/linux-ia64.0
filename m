From: "Arnd Bergmann" <arnd@arndb.de>
Date: Mon, 17 Apr 2023 09:22:24 +0000
Subject: Re: [PATCH v2 01/19] fbdev: Prepare generic architecture helpers
Message-Id: <55abd7af-acb8-47ce-89db-1722bcf0cb9c@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230406143019.6709-1-tzimmermann@suse.de>
 <20230406143019.6709-2-tzimmermann@suse.de>
 <CAMuHMdUfViWzPbB+GcGUwxmGNxAohfq71Jed3DzS=Cb+gBzotg@mail.gmail.com>
 <2b4f75b8-aa83-8e41-7c99-7c8d573c0f31@suse.de>
In-Reply-To: <2b4f75b8-aa83-8e41-7c99-7c8d573c0f31@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Thomas Zimmermann <tzimmermann@suse.de>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Helge Deller <deller@gmx.de>, Javier Martinez Canillas <javierm@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Mon, Apr 17, 2023, at 11:03, Thomas Zimmermann wrote:
> Am 11.04.23 um 10:08 schrieb Geert Uytterhoeven:
>> On Thu, Apr 6, 2023 at 4:30=E2=80=AFPM Thomas Zimmermann <tzimmermann@su=
se.de> wrote:

>>> +#ifndef fb_pgprotect
>>> +#define fb_pgprotect fb_pgprotect
>>> +static inline void fb_pgprotect(struct file *file, struct vm_area_stru=
ct *vma,
>>> +                               unsigned long off)
>>=20
>> Does this affect any noMMU platforms that relied on fb_pgprotect()
>> doing nothing before?
>> Perhaps the body below should be protected by "#ifdef CONFIG_MMU"?
>
> I cannot conclusively answer this question, but I did some grep'ing=20
> ('git grep ndef | grep CONFIG_MMU'):
>
> Only the architectures in this patchset provide <asm/fb.h> but nothing=20
> anywhere uses <asm-generic/fb.h> yet. And of those architectures, only=20
> arm and m68k have !CONFIG_MMU cases. Those are handled in the rsp=20
> patches. I think we're good.

Agreed. The generic version is just a more elaborate way to do
nothing here, as the=20

     vma->vm_page_prot =3D pgprot_writecombine(vma->vm_page_prot);

line on nommu just turns into a self-assignment of the same member
that was set the line before.

     Arnd
