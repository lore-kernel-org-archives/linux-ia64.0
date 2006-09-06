From: Greg KH <greg@kroah.com>
Date: Wed, 06 Sep 2006 18:45:09 +0000
Subject: Re: [stable] [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <20060906184509.GA15942@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org> <Pine.LNX.4.64.0609061120430.27779@g5.osdl.org> <20060906182733.GJ2558@parisc-linux.org>
In-Reply-To: <20060906182733.GJ2558@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Linus Torvalds <torvalds@osdl.org>, Kirill Korotaev <dev@openvz.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org, Fernando Vazquez <fernando@oss.ntt.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable@kernel.org, "David S. Miller" <davem@davemloft.net>, devel@openvz.org, xemul@openvz.org

On Wed, Sep 06, 2006 at 12:27:33PM -0600, Matthew Wilcox wrote:
> On Wed, Sep 06, 2006 at 11:24:05AM -0700, Linus Torvalds wrote:
> > If MIPS and parisc don't matter for the stable tree (very possible - there 
> > are no big commercial distributions for them), then dammit, neither should 
> > ia64 and sparc (there are no big commercial distros for them either). 
> 
> Erm, RHEL and SLES both support ia64.

Yes, but the -stable developers don't build for those arches, that's why
it was missed here.

So, what's the proper patch for the next -stable release to fix this
problem?  I see a bunch of different ones floating around...

thanks,

greg k-h
