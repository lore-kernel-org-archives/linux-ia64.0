From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 18:51:22 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434479111278@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 11:51:04 -0700
Grant Grundler <iod00d@hp.com> wrote:

> Even x86 pays at least a one cycle penalty for every misaligned access.

Yes, one cycle, and it's completely lost in the noise when it
happens.

> In general, open source code has no excuse for using misaligned fields.
> It's (mostly) avoidable.  TCP/IP headers are the historical exception.

It's not the TCP/IP headers intrinsically, it's what they are embedded
inside of.

For example, if the ethernet driver (as nearly all of our's do which
can) optimized for an ethernet header followed by an IP header, guess
what?  That causes ethernet header followed by appletalk followed
by IP to do unaligned accesses.

It is an unavoidable axoim in the kernel networking.  Unaligned accesses
will happen, and they aren't a bug and therefore not worthy of mention
in the kernel logs any more than "page was freed" :-)
