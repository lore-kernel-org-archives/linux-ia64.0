From: "Antonino A. Daplas" <adaplas@gmail.com>
Date: Thu, 06 Apr 2006 01:49:55 +0000
Subject: Re: 2.6.17-rc1-mm1
Message-Id: <443473C3.4050807@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060404014504.564bf45a.akpm@osdl.org> <200604051015.34217.bjorn.helgaas@hp.com> <20060405211757.GA8536@agluck-lia64.sc.intel.com> <200604051601.08776.bjorn.helgaas@hp.com>
In-Reply-To: <200604051601.08776.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Zou Nan hai <nanhai.zou@intel.com>, Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:
> On Wednesday 05 April 2006 15:17, Luck, Tony wrote:
>> On Wed, Apr 05, 2006 at 10:15:34AM -0600, Bjorn Helgaas wrote:

> [PATCH] vgacon: make VGA_MAP_MEM take size, remove extra use
> 
> VGA_MAP_MEM translates to ioremap() on some architectures.  It
> makes sense to do this to vga_vram_base, because we're going to
> access memory between vga_vram_base and vga_vram_end.
> 
> But it doesn't really make sense to map starting at vga_vram_end,
> because we aren't going to access memory starting there.  On ia64,
> which always has to be different, ioremapping vga_vram_end gives
> you something completely incompatible with ioremapped vga_vram_start,
> so vga_vram_size ends up being nonsense.
> 
> As a bonus, we often know the size up front, so we can use ioremap()
> correctly, rather than giving it a zero size.

I definitely prefer this patch.

> 
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Acked-by: Antonino Daplas <adaplas@pol.net>

Tony
