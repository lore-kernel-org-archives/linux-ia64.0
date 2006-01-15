From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Sun, 15 Jan 2006 15:46:16 +0000
Subject: Re: [linux-usb-devel] Re: [2.6 patch] remove unused tmp_buf_sem's
Message-Id: <1137339976.2350.2.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <17348.61824.49889.569928@jaguar.mkp.net>
	 <20060114020816.GW29663@stusta.de>  <20060114034903.GA23074@suse.de>
In-Reply-To: <20060114034903.GA23074@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@suse.de>
Cc: Adrian Bunk <bunk@stusta.de>, Jes Sorensen <jes@trained-monkey.org>, torvalds@osdl.org, akpm@osdl.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-usb-devel@lists.sourceforge.net, R.E.Wolff@BitWizard.nl, paulus@samba.org, linuxppc-dev@ozlabs.org

On Gwe, 2006-01-13 at 19:49 -0800, Greg KH wrote:
> On Sat, Jan 14, 2006 at 03:08:16AM +0100, Adrian Bunk wrote:
> > <--  snip  -->
> > 
> > 
> > tmp_buf_sem sems to be a common name for something completely unused...


That would be correct. The old tty driver layer used to call ->write
from both kernel and user contexts according to a flag. Drivers then all
ended up with the same code copying it into a tmp buffer and using a
locking semaphore. 

Linus took out that code and arranged that ->write always got a kernel
buffer so the remainders should indeed go.

Alan

