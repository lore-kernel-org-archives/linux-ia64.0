From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 19:01:10 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434479311303@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 21:09:47 +0200
Andreas Schwab <schwab@suse.de> wrote:

> The compiler is allowed to take advantage that there are no unaligned
> accesses.  You need to use compiler extensions (like attribute packed) to
> stop it from doing this.

That's correct, and if the address is misaligned the cpu "traps"
and the kernel fixes up the load/store access to fix it up.

This unaligned trap handling is required for a port of Linux to
a given cpu architecture.

That's what we're talking about here.
