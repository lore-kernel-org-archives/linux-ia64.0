From: Helge Deller <deller@gmx.de>
Date: Wed, 19 Apr 2023 17:22:50 +0000
Subject: Re: [PATCH v3 00/19] arch: Consolidate <asm/fb.h>
Message-Id: <b1f90fa4-85c7-e785-ba14-f32962f87d5e@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230417125651.25126-1-tzimmermann@suse.de>
 <1641007d-7953-426a-a3de-ca9c90f6c5a9@app.fastmail.com>
 <5fa98536-a4b0-7b71-7342-9ba05158062f@suse.de>
In-Reply-To: <5fa98536-a4b0-7b71-7342-9ba05158062f@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, Arnd Bergmann <arnd@arndb.de>, Daniel Vetter <daniel.vetter@ffwll.ch>, Javier Martinez Canillas <javierm@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

Hi Thomas,

> Am 17.04.23 um 16:12 schrieb Arnd Bergmann:>> On Mon, Apr 17, 2023, at 14:56, Thomas Zimmermann wrote:
>>> Various architectures provide <asm/fb.h> with helpers for fbdev
>>> framebuffer devices. Share the contained code where possible. There
>>> is already <asm-generic/fb.h>, which implements generic (as in
>>> 'empty') functions of the fbdev helpers. The header was added in
>>> commit aafe4dbed0bf ("asm-generic: add generic versions of common
>>> headers"), but never used.
>>>
>>> Each per-architecture header file declares and/or implements fbdev
>>> helpers and defines a preprocessor token for each. The generic
>>> header then provides the remaining helpers. It works like the I/O
>>> helpers in <asm/io.h>.
>>
>> Looks all good to me,
>>
>> Acked-by: Arnd Bergmann <arnd@arndb.de>
>
> Thanks a lot. I know that Helge wants to test the PARISC changes, so
> I'll keep this series pending for a bit longer. I'd like to merge the
> patches through the DRM tree, if no one objects.

Yes, patch is good and I've tested it on parisc. Thanks!

You may add:
Acked-by: Helge Deller <deller@gmx.de>
to the series and take it through the drm tree.

Helge
