From: "Arnd Bergmann" <arnd@arndb.de>
Date: Thu, 11 May 2023 12:48:58 +0000
Subject: Re: [PATCH v6 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <4976d32d-b73f-49e5-9e15-78786d77dc8f@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510110557.14343-6-tzimmermann@suse.de>
 <202305102136.eMjTSPwH-lkp@intel.com>
 <f6b2d541-d235-4e98-afcc-9137fb8afa35@app.fastmail.com>
 <49684d58-c19d-b147-5e9f-2ac526dd50f0@suse.de>
 <743d2b1e-c843-4fb2-b252-0006be2e2bd8@app.fastmail.com>
 <CAMuHMdVvR1jdbZS8KoMf4R3zhLRWKv9XbG61iBGOGGZPHB+taA@mail.gmail.com>
In-Reply-To: 
 <CAMuHMdVvR1jdbZS8KoMf4R3zhLRWKv9XbG61iBGOGGZPHB+taA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Thomas Zimmermann <tzimmermann@suse.de>, kernel test robot <lkp@intel.com>, Helge Deller <deller@gmx.de>, Javier Martinez Canillas <javierm@redhat.com>, Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, "David S . Miller" <davem@davemloft.net>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, Sam Ravnborg <sam@ravnborg.org>, suijingfeng@loongson.cn, oe-kbuild-all@lists.linux.dev, Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Artur Rojek <contact@artur-rojek.eu>

On Thu, May 11, 2023, at 14:35, Geert Uytterhoeven wrote:
> CC Artur, who's working on HP Jornada 680.
>
> On Wed, May 10, 2023 at 5:55=E2=80=AFPM Arnd Bergmann <arnd@arndb.de> wro=
te:
>> On Wed, May 10, 2023, at 16:27, Thomas Zimmermann wrote:
>> > Am 10.05.23 um 16:15 schrieb Arnd Bergmann:
>> >> On Wed, May 10, 2023, at 16:03, kernel test robot wrote:
>
> See also commit 4aafae27d0ce73f8 ("sh: hd64461 tidying."), which
> claims they are no longer needed.
>
> Don't the I/O port macros just treat the port as an absolute base address
> when sh_io_port_base isn't set?

As far as I can tell, sh_io_port_base gets initialized to '-1'
specifically to prevent that from working by accident. So it's
almost treated as an absolute base address, but the off-by-one
offset ensures this never actually works unless it was first
set to the correct value.

      Arnd
