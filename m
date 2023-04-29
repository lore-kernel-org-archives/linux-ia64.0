From: "Arnd Bergmann" <arnd@arndb.de>
Date: Sat, 29 Apr 2023 14:11:13 +0000
Subject: Re: [PATCH v2 5/5] fbdev: Define framebuffer I/O from Linux' I/O functions
Message-Id: <260ee591-a71b-4c83-a775-5591d4222cec@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-6-tzimmermann@suse.de>
 <430c73f0-45f4-f81e-6506-bc8cc955d936@arm.com>
 <CAMuHMdUGjtiAR37L4_e0_p8ee2=gxoUj7+e7rqMLTBK+vpV4yw@mail.gmail.com>
 <f612c682-5767-4a58-82f6-f4a4d1b592a1@app.fastmail.com>
 <df6fa134-3a62-0872-e008-393e4a29a5ab@suse.de>
In-Reply-To: <df6fa134-3a62-0872-e008-393e4a29a5ab@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Robin Murphy <robin.murphy@arm.com>
Cc: Helge Deller <deller@gmx.de>, Javier Martinez Canillas <javierm@redhat.com>, Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, "David S . Miller" <davem@davemloft.net>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, Sam Ravnborg <sam@ravnborg.org>, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

On Sat, Apr 29, 2023, at 14:26, Thomas Zimmermann wrote:
> Am 28.04.23 um 15:17 schrieb Arnd Bergmann:
>> The only implementations in fbdev are
>> 
>>   1) sparc sbus
>>   2) __raw_writel
>>   3) direct pointer dereference
>> 
>> But none use the byte-swapping writel() implementations, and
>> the only ones that use the direct pointer dereference or sbus
>> are the ones on which these are defined the same as __raw_writel
>
> After thinking a bit more about the requirements, I'd like to got back 
> to v1, but with a different spin. We want to avoid ordering guarantees, 
> so I looked at the _relaxed() helpers, but they seem to swap bytes to 
> little endian.

Right, the _relaxed() oens are clearly wrong, aside from
the byteswap they also include barriers on some architectures
where the __raw_* version is more relaxed than the required
semantics for relaxed.

> I guess we can remove the fb_mem*() functions entirely. They are the 
> same as the non-fb_ counterparts.

These might actually be different in some cases, or sub-optimal
at the moment. memcpy()/memset() don't take __iomem pointers, so they
cause sparse warnings, while the memset_io()/memcpy_fromio()/
memcpy_toio() sometimes fall back to bytewise access that is slower
than word-sized copy. I only looked at the readl/writel style 
functions earlier, no idea what we want here.

> For the fb read/write helpers, I'd 
> like to add them to <asm-generic/fb.h> in a platform-neutral way. They'd 
> be wrappers around __raw_(), as I wouldn't want invocations of  __raw_() 
> functions in the fbdev drivers.

That sounds good to me.

     Arnd
