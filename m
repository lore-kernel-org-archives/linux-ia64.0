From: William Lee Irwin III <wli@holomorphy.com>
Date: Wed, 24 Sep 2003 01:58:41 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106436898504618@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 04:35:42PM -0700, David S. Miller wrote:
> That's a amusing coincidence since at least some people think ia64
> will end up the same way the i860 did :-)
> In the past I did always advocate things the way you are right now,
> but these days I think I've been wrong the whole time and Intel on x86
> is doing the right thing.
> They do everything in hardware and this makes the software so much
> simpler.  Sure, there's a lot of architectually inherited complexity
> in the x86 family, but their engineering priorities mean there is so
> much other stuff you simply never have to think about as a programmer.

Several of the x86 "hardware assists" need some rather hefty hacks
codewise to cope with their concomitant data structure proliferations
under industrial workloads, and generally have me begging for RISC's
system-level features instead (which, of course, require various
undoings of Linux' x86 crossdressings to exploit).

Given the reactions in prior threads, this message clearly needs to
wait a long while before it will ever be heard.


-- wli
