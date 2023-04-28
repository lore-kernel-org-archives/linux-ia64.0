From: "Arnd Bergmann" <arnd@arndb.de>
Date: Fri, 28 Apr 2023 13:17:24 +0000
Subject: Re: [PATCH v2 5/5] fbdev: Define framebuffer I/O from Linux' I/O functions
Message-Id: <f612c682-5767-4a58-82f6-f4a4d1b592a1@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-6-tzimmermann@suse.de>
 <430c73f0-45f4-f81e-6506-bc8cc955d936@arm.com>
 <CAMuHMdUGjtiAR37L4_e0_p8ee2=gxoUj7+e7rqMLTBK+vpV4yw@mail.gmail.com>
In-Reply-To: 
 <CAMuHMdUGjtiAR37L4_e0_p8ee2=gxoUj7+e7rqMLTBK+vpV4yw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Geert Uytterhoeven <geert@linux-m68k.org>, Robin Murphy <robin.murphy@arm.com>
Cc: Thomas Zimmermann <tzimmermann@suse.de>, Helge Deller <deller@gmx.de>, Javier Martinez Canillas <javierm@redhat.com>, Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, "David S . Miller" <davem@davemloft.net>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, Sam Ravnborg <sam@ravnborg.org>, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

On Fri, Apr 28, 2023, at 13:27, Geert Uytterhoeven wrote:
> On Fri, Apr 28, 2023 at 2:18=E2=80=AFPM Robin Murphy <robin.murphy@arm.co=
m> wrote:
>> On 2023-04-28 10:27, Thomas Zimmermann wrote:

>> > -
>> > -#elif defined(__i386__) || defined(__alpha__) || defined(__x86_64__) =
||      \
>> > -     defined(__hppa__) || defined(__sh__) || defined(__powerpc__) || \
>> > -     defined(__arm__) || defined(__aarch64__) || defined(__mips__)
>> > -
>> > -#define fb_readb __raw_readb
>> > -#define fb_readw __raw_readw
>> > -#define fb_readl __raw_readl
>> > -#define fb_readq __raw_readq
>> > -#define fb_writeb __raw_writeb
>> > -#define fb_writew __raw_writew
>> > -#define fb_writel __raw_writel
>> > -#define fb_writeq __raw_writeq
>>
>> Note that on at least some architectures, the __raw variants are
>> native-endian, whereas the regular accessors are explicitly
>> little-endian, so there is a slight risk of inadvertently changing
>> behaviour on big-endian systems (MIPS most likely, but a few old ARM
>> platforms run BE as well).
>
> Also on m68k, when ISA or PCI are enabled.
>
> In addition, the non-raw variants may do some extras to guarantee
> ordering, which you do not need on a frame buffer.
>
> So I'd go for the __raw_*() variants everywhere.

The only implementations in fbdev are

 1) sparc sbus
 2) __raw_writel
 3) direct pointer dereference

But none use the byte-swapping writel() implementations, and
the only ones that use the direct pointer dereference or sbus
are the ones on which these are defined the same as __raw_writel

      Arnd
