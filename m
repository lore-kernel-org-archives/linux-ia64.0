From: Andrew Morton <akpm@osdl.org>
Date: Tue, 23 Sep 2003 23:15:29 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106435893428994@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"David S. Miller" <davem@redhat.com> wrote:
>
> > That's not true; they could be avoided by using get_unaligned() and
>  > put_unaligned().  You just don't want to because they'd make sparc suck.
> 
>  Not only sparc would be effected by this.  Using {get,put}_unaligned()
>  all over the networking would incur a penalty for many platforms, not
>  just sparc.

Really?  I'd have thought that get/put_unaligned would be a simple
load/store for architectures which wish to implement it in that manner.

Other architectures could take it as an optimisation hint, to avoid taking
a trap.  They'd probably still need to implement the fixup, but if a few of
these hints could reduce the trap frequency significantly then it may be
worth doing?

I guess it depends on how many of these hints would be needed at the source
level to avoid "most" of the traps.

