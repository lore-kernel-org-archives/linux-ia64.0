From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 01 Feb 2005 09:10:10 +0000
Subject: Re: [PATCH 2.6.11] Altix patch for device driver support for the CX port of SGI's TIO chip
Message-Id: <20050201091010.GA28575@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0501311506590.30646-100000@fsgi025.americas.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0501311506590.30646-100000@fsgi025.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jan 31, 2005 at 05:13:15PM -0600, Bruce Losure wrote:
> 
> Christoph,
> 
> Thanks for your comments.   I'll make the typedef and #include line
> changes.  Should'a caught the include stuff myself :-(.    I plan to
> go ahead and move the code into drivers/char/sn and make the Kconfig
> changes.   Is that what you mean by 'driver model'?

No.  It means to use the generic code in drivers/base/ for device matching,
device lists, sysfs exposure, etc..  look at pci or usb for details.

> Also, what is the alternative to the ioctl interface?   Should I move
> that functionality to /proc?

the device list you get for free in sysfs when using the driver model,
the reload one can easily be implemented as attribute in sysfs, check
e.g. the scsi rescan attribute for something similar.

