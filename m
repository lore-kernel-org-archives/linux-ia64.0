From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 23:35:42 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106436026430218@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 15:35:40 -0700
Grant Grundler <iod00d@hp.com> wrote:

> And someone at Intel obviously agrees the newer architectures
> should support misaligned access in SW since ever RISC chip
> they've built (starting with i860, ~1989) does it that way.

That's a amusing coincidence since at least some people think ia64
will end up the same way the i860 did :-)

In the past I did always advocate things the way you are right now,
but these days I think I've been wrong the whole time and Intel on x86
is doing the right thing.

They do everything in hardware and this makes the software so much
simpler.  Sure, there's a lot of architectually inherited complexity
in the x86 family, but their engineering priorities mean there is so
much other stuff you simply never have to think about as a programmer.

