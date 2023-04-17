From: "Arnd Bergmann" <arnd@arndb.de>
Date: Mon, 17 Apr 2023 14:12:15 +0000
Subject: Re: [PATCH v3 00/19] arch: Consolidate <asm/fb.h>
Message-Id: <1641007d-7953-426a-a3de-ca9c90f6c5a9@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230417125651.25126-1-tzimmermann@suse.de>
In-Reply-To: <20230417125651.25126-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, Daniel Vetter <daniel.vetter@ffwll.ch>, Helge Deller <deller@gmx.de>, Javier Martinez Canillas <javierm@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Mon, Apr 17, 2023, at 14:56, Thomas Zimmermann wrote:
> Various architectures provide <asm/fb.h> with helpers for fbdev
> framebuffer devices. Share the contained code where possible. There
> is already <asm-generic/fb.h>, which implements generic (as in
> 'empty') functions of the fbdev helpers. The header was added in
> commit aafe4dbed0bf ("asm-generic: add generic versions of common
> headers"), but never used.
>
> Each per-architecture header file declares and/or implements fbdev
> helpers and defines a preprocessor token for each. The generic
> header then provides the remaining helpers. It works like the I/O
> helpers in <asm/io.h>.

Looks all good to me,

Acked-by: Arnd Bergmann <arnd@arndb.de>

     Arnd
