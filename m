From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 20:45:29 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106435072819678@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 13:38:19 -0700
Grant Grundler <iod00d@hp.com> wrote:

> Given misaligned accesses are infrequent enough to affect
> performance, it makes sense to do this in SW because
> it reduces cost of the HW design/test/mfg cycles.

Intel actually optimizes this on the P4, what is your
response to that?  Is Intel wasting they time? :-)

> Ok. If the kernel networking stack used get_unaligned() in the one place
> Peter originally found, x86/sparc64?/et al wouldn't see a difference.
> It would avoid traps on ia64 and parisc.  Bad idea?
> Any other arches it might help/hurt on?

It's needed on every access to every TCP and IP header portion
for the case we're talking about in this thread, where the network
device driver gives the networking a packet that ends up with
unaligned IP and TCP headers.

I once considered adding some get_unaligned() uses to the TCP option
parsing code, guess who rejected that patch?  It wasn't me, it was
Linus himself and I came to learn that he's right on this one.
