From: Grant Grundler <iod00d@hp.com>
Date: Tue, 23 Sep 2003 22:35:40 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106435656026586@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 01:45:29PM -0700, David S. Miller wrote:
> Intel actually optimizes this on the P4, what is your
> response to that?  Is Intel wasting they time? :-)

nono...but Intel doesn't have a choice on x86.
They have to optimize for the binaries that are out there.
Compatibility is everything in that market space.

And someone at Intel obviously agrees the newer architectures
should support misaligned access in SW since ever RISC chip
they've built (starting with i860, ~1989) does it that way.

> It's needed on every access to every TCP and IP header portion
> for the case we're talking about in this thread, where the network
> device driver gives the networking a packet that ends up with
> unaligned IP and TCP headers.

Yeah, I don't use most LAN features (PPPoE, VLAN, Appletalk, etc).
I naively thought there must be a subset everyone uses...but defining
that subset sounds like a rat hole I shouldn't go near.

> I once considered adding some get_unaligned() uses to the TCP option
> parsing code, guess who rejected that patch?  It wasn't me, it was
> Linus himself and I came to learn that he's right on this one.

I'm not totally comfortable with that. The NICs I care about seem to
"bias the buffer address" to compensate for some "common case".
Seems like those cases would be cheaper (and more portable) to add
the get_unaligned() calls in the networking stack....I don't know
though really.

thanks,
grant
