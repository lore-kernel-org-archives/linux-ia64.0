From: "Arnd Bergmann" <arnd@arndb.de>
Date: Wed, 03 May 2023 15:06:36 +0000
Subject: Re: [PATCH v3 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <2054ae6a-dcf9-42a3-9850-dd2587d40c58@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230502130223.14719-1-tzimmermann@suse.de>
 <20230502130223.14719-6-tzimmermann@suse.de>
 <67d6a188-041f-4604-99a3-548c41af0693@app.fastmail.com>
 <dd921bae-0145-09e2-24b1-f08d89a78eba@suse.de>
In-Reply-To: <dd921bae-0145-09e2-24b1-f08d89a78eba@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, Helge Deller <deller@gmx.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Javier Martinez Canillas <javierm@redhat.com>, Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, "David S . Miller" <davem@davemloft.net>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Sam Ravnborg <sam@ravnborg.org>
Cc: linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

On Wed, May 3, 2023, at 16:55, Thomas Zimmermann wrote:
> Am 02.05.23 um 22:06 schrieb Arnd Bergmann:

>> It's probably safe to deal with all the above by either adding
>> architecture specific overrides to the current version, or
>> by doing the semantic changes before the move to asm/fb.h, but
>> one way or the other I'd prefer this to be separate from the
>> consolidation patch that should not have any changes in behavior.
>
> I think I'll add architecture overrides that contain the current code, 
> even if they contain some force-casting wrt __iomem. If anyone wants to 
> fix the issues, they can then address them easily.

Ok, sounds good,

     Arnd
