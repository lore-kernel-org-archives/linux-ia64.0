From: Matthew Wilcox <willy@debian.org>
Date: Wed, 24 Sep 2003 00:14:56 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106436275432269@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 04:37:44PM -0700, David S. Miller wrote:
> > >  Not only sparc would be effected by this.  Using {get,put}_unaligned()
> > >  all over the networking would incur a penalty for many platforms, not
> > >  just sparc.
> > 
> > Really?  I'd have thought that get/put_unaligned would be a simple
> > load/store for architectures which wish to implement it in that manner.
> 
> Only on systems that have the "load upper/lower-unaligned"
> instructions.  On others it's a memmove().

It is at the moment, but why should it be?  Why can't it be implemented
as load-and-trap if that's the fastest way to do it?

(I can see this descending into get_unaligned_likely() and
get_aligned_unlikely() which i'd rather avoid ...)

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
