From: Andi Kleen <ak@suse.de>
Date: Wed, 28 Jan 2004 19:19:22 +0000
Subject: Re: [RFC/PATCH, 2/4] readX_check() performance evaluation
Message-Id: <20040128201922.2dc7bec7.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a301c3e541$c13a6350$2987110a@lsd.css.fujitsu.com>
	<Pine.LNX.4.58.0401271847440.10794@home.osdl.org>
	<20040128182003.GL11844@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040128182003.GL11844@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@debian.org>
Cc: torvalds@osdl.org, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 28 Jan 2004 18:20:03 +0000
Matthew Wilcox <willy@debian.org> wrote:


> If there are, Linus' interface is probably the best one.  If not, we could
> simply have readX_check() / writeX_check() call dev->driver->unregister()
> if they notice an error has occurred and then the driver doesn't even
> need to call read_pcix_errors().

It just won't really work for platforms with inexact MCEs for IO errors.
And even for those with exact MCEs it would probably be a nightmare
to implement (writing MCE handlers is extremly hard because you cannot
rely on any locking guarantees - even a printk can randomly deadlock)

For those the per pci_dev callback is the only realistic way.

-Andi
