From: Greg KH <greg@kroah.com>
Date: Fri, 19 Mar 2004 22:13:19 +0000
Subject: Re: [0/3] Make pci resources show up in iomem/ioport on ia64
Message-Id: <20040319221319.GB14128@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040318235024.GH25059@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040318235024.GH25059@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@debian.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@zip.com.au>, David Mosberger <davidm@hpl.hp.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Mar 18, 2004 at 11:50:24PM +0000, Matthew Wilcox wrote:
> 
> I decided to do one simple little thing -- make PCI device resources show
> up in /proc/iomem and /proc/ioport on ia64 just like they do on i386.
> Of course, I found two bugs in the process so we have three logically
> separate patches that I shall be sending in reply to this message.

I've applied all 3 of these patches, thanks.

greg k-h
