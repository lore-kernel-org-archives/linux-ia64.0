From: "Arnd Bergmann" <arnd@arndb.de>
Date: Wed, 03 May 2023 08:52:34 +0000
Subject: Re: [PATCH v3 4/6] fbdev: Include <linux/io.h> via <asm/fb.h>
Message-Id: <0ecbc92c-7e42-4958-988b-abc265f039bf@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230502130223.14719-1-tzimmermann@suse.de>
 <20230502130223.14719-5-tzimmermann@suse.de>
 <20230502195429.GA319489@ravnborg.org>
 <563673c0-799d-e353-974c-91b1ab881a22@suse.de>
 <87354dyj9i.fsf@minerva.mail-host-address-is-not-set>
 <97bbdb2f-6245-caf2-c0f6-d628873bd6db@suse.de>
In-Reply-To: <97bbdb2f-6245-caf2-c0f6-d628873bd6db@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, Javier Martinez Canillas <javierm@redhat.com>, Sam Ravnborg <sam@ravnborg.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Helge Deller <deller@gmx.de>, Huacai Chen <chenhuacai@kernel.org>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, linux-m68k@lists.linux-m68k.org, Geert Uytterhoeven <geert@linux-m68k.org>, loongarch@lists.linux.dev, Vineet Gupta <vgupta@kernel.org>, sparclinux@vger.kernel.org, WANG Xuerui <kernel@xen0n.name>, linux-snps-arc@lists.infradead.org, "David S . Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org

On Wed, May 3, 2023, at 10:12, Thomas Zimmermann wrote:
> Am 03.05.23 um 09:19 schrieb Javier Martinez Canillas:
>> Thomas Zimmermann <tzimmermann@suse.de> writes:
>>>>
>>>> There are countless examples where the above are not followed,
>>>> but to my best understanding the above it the preferred way to do it.
>>>
>>> Where did youher this? I only know about this in the case of asm/io.h
>>> vs. linux/io.h.
>>>
>> 
>> I understand that's the case too. I believe even checkpatch.pl complains
>> about it? (not that the script always get right, but just as an example).
>
> Do you know if that's the general rule? If so, we might want to 
> repurpose <asm/fbio.h> for the framebuffer I/O functions.

It's certainly the general trend across all of the kernel to have
drivers prefer including linux/*.h, and to move stuff from asm/*.h
to linux/*.h as it gets generalized across architectures.

     Arnd
