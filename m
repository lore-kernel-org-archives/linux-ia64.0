From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 07 Jan 2005 17:47:46 +0000
Subject: RE: [patch] per cpu MCA/INIT fixes.
Message-Id: <1105120066.25267.25.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060308.j0638M7s194286@ben.americas.sgi.com>
In-Reply-To: <200501060308.j0638M7s194286@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2005-01-06 at 22:51 -0800, Luck, Tony wrote:
> >An updated patch that applies on Jack's and builds with zx1 & tiger UP.
> >The SGI UP is previously broke.  Jesse is working on that.
> 
> Build for tiger_defconfig looked pretty clean, but it doesn't boot :-(
> 
> No messages to console or serial console.  Peering into memory, I see
> this in __log_buf:

Most people don't have this mystical ability to peer into
memory :-).  You *should* be able to get this information
easily from a serial console with "console=uart,io,0x2f8".

(For some reason tiger hides ttyS0 (0x3f8) somewhere, and
the port on the back panel is actually ttyS1 (0x2f8)).

