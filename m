From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 06 Apr 2006 14:55:27 +0000
Subject: Re: 2.6.17-rc1-mm1
Message-Id: <200604060855.27673.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060404014504.564bf45a.akpm@osdl.org> <20060406102154.GB28056@flint.arm.linux.org.uk> <20060406103427.GC28056@flint.arm.linux.org.uk>
In-Reply-To: <20060406103427.GC28056@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <rmk+lkml@arm.linux.org.uk>
Cc: "Luck, Tony" <tony.luck@intel.com>, Zou Nan hai <nanhai.zou@intel.com>, Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Thursday 06 April 2006 04:34, Russell King wrote:
> On Thu, Apr 06, 2006 at 11:21:54AM +0100, Russell King wrote:
> > On Wed, Apr 05, 2006 at 04:01:08PM -0600, Bjorn Helgaas wrote:
> > > [PATCH] vgacon: make VGA_MAP_MEM take size, remove extra use
> > 
> > Ah, seems to be what I just suggested...
> > 
> > > @@ -1020,14 +1019,14 @@
> > >  	char *charmap;
> > >  	
> > >  	if (vga_video_type != VIDEO_TYPE_EGAM) {
> > > -		charmap = (char *) VGA_MAP_MEM(colourmap);
> > > +		charmap = (char *) VGA_MAP_MEM(colourmap, 0);
> > 
> > Don't like this though - can't we pass a real size here rather than zero?
> > There seems to be several clues as to the maximum size:

I didn't like it either, but was too lazy to work out the actual size,
so I just preserved the previous behavior.

Andrew's put my first patch in -mm already, so I'll put this size
issue and your unmap suggestion on my to-do list.
