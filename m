From: Russell King <rmk+lkml@arm.linux.org.uk>
Date: Thu, 06 Apr 2006 10:21:54 +0000
Subject: Re: 2.6.17-rc1-mm1
Message-Id: <20060406102154.GB28056@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060404014504.564bf45a.akpm@osdl.org> <200604051015.34217.bjorn.helgaas@hp.com> <20060405211757.GA8536@agluck-lia64.sc.intel.com> <200604051601.08776.bjorn.helgaas@hp.com>
In-Reply-To: <200604051601.08776.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Zou Nan hai <nanhai.zou@intel.com>, Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, Apr 05, 2006 at 04:01:08PM -0600, Bjorn Helgaas wrote:
> [PATCH] vgacon: make VGA_MAP_MEM take size, remove extra use

Ah, seems to be what I just suggested...

> @@ -1020,14 +1019,14 @@
>  	char *charmap;
>  	
>  	if (vga_video_type != VIDEO_TYPE_EGAM) {
> -		charmap = (char *) VGA_MAP_MEM(colourmap);
> +		charmap = (char *) VGA_MAP_MEM(colourmap, 0);

Don't like this though - can't we pass a real size here rather than zero?
There seems to be several clues as to the maximum size:

#define cmapsz 8192

        if (!vga_font_is_default)
                charmap += 4 * cmapsz;

                        charmap += 2 * cmapsz;
                                for (i = 0; i < cmapsz; i++)
                                        vga_writeb(arg[i], charmap + i);

so that's about 7 * cmapsz - call that 8 for completeness, which is 64K.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
