From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 24 Apr 2002 19:45:51 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905515@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

After an enlightening discussion with Mr. Miller, my patch stands as
is.  Does it look good enough to integrate into the next release?  If
not, what should I clean up?

Thanks a lot,
Jesse

On Mon, Apr 22, 2002 at 04:07:33PM -0700, David Mosberger wrote:
> >>>>> On Mon, 22 Apr 2002 15:39:46 -0700, Jesse Barnes <jbarnes@sgi.com> said:
> 
>   Jesse> Except that pci_alloc_consistent is supposed to return a 32
>   Jesse> bit address...
> 
> Oh man, what a mess!  Have you checked with Dave Miller?  I suspect
> he might not like this.  I'm not terribly fond of it either as it
> makes it even more confusing as to when to use the DAC interface.  I'd
> rather see a separate "alloc_consistent" routine, which doesn't isn't
> on <4GB addresses.
> 
> 	--david

