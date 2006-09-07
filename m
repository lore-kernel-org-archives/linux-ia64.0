From: Greg KH <greg@kroah.com>
Date: Thu, 07 Sep 2006 15:37:46 +0000
Subject: Re: [stable] [PATCH] IA64,sparc: local DoS with corrupted ELFs
Message-Id: <20060907153746.GA29602@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44FC193C.4080205@openvz.org> <Pine.LNX.4.64.0609061120430.27779@g5.osdl.org> <20060906182733.GJ2558@parisc-linux.org> <20060906184509.GA15942@kroah.com> <20060906191215.GK2558@parisc-linux.org> <20060906192511.GA14579@kroah.com> <1157634702.30159.89.camel@aeonflux.holtmann.net>
In-Reply-To: <1157634702.30159.89.camel@aeonflux.holtmann.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcel Holtmann <marcel@holtmann.org>
Cc: Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@osdl.org>, Kirill Korotaev <dev@openvz.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org, Fernando Vazquez <fernando@oss.ntt.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable@kernel.org, "David S. Miller" <davem@davemloft.net>, devel@openvz.org, xemul@openvz.org

On Thu, Sep 07, 2006 at 03:11:42PM +0200, Marcel Holtmann wrote:
> Hi Greg,
> 
> > > > Yes, but the -stable developers don't build for those arches, that's why
> > > > it was missed here.
> > > 
> > > What's the easiest way to get coverage here?  Sending a parisc
> > > workstation or server to someone?  Giving accounts to some/all of the
> > > stable team?  Finding someone who cares about parisc to join the stable
> > > team?
> > 
> > How about: Someone from that arch trying out the -stable release
> > canidates to make sure it doesn't break anything on their arches /
> > favorite machine?
> 
> this won't work for security hot-fixes, because you basically don't do a
> release candidate for them. We should think about this, too.

Well, short of me and Chris getting one of every arch out there (which I
don't recommend), I think we will just get by as we have been doing in
the past.

thanks,

greg k-h
