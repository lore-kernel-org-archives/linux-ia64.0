From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 28 Apr 2023 16:54:12 +0000
Subject: Re: [PATCH v2 5/5] fbdev: Define framebuffer I/O from Linux' I/O functions
Message-Id: <20230428165412.GA4010212@ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230428092711.406-1-tzimmermann@suse.de>
 <20230428092711.406-6-tzimmermann@suse.de>
 <20230428131221.GE3995435@ravnborg.org>
 <900eaf1c-4d29-2c26-c220-6b4e089d9b94@suse.de>
In-Reply-To: <900eaf1c-4d29-2c26-c220-6b4e089d9b94@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

Hi Thomas,

On Fri, Apr 28, 2023 at 04:18:38PM +0200, Thomas Zimmermann wrote:
> I'd be happy to have fb_() wrappers that are I/O helpers without
> ordering guarantees. I'd just wouldn't want them in <linux/fb.h>

How about throwing them into a new drm_fb.h header file.
This header file could be the home for all the fb stuff that is
shared between drm and the legacy fbdev.

Then we may slowly migrate more fbdev stuff to drm and let the legacy
fbdev stuff use the maintained drm stuff.
Dunno, the pain may not be worth it.

	Sam
