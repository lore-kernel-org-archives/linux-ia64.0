From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 01 Jul 2003 22:53:20 +0000
Subject: Re: [Linux-ia64] RTC support on ia64
Message-Id: <marc-linux-ia64-105710020717164@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805600@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805600@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Eric" = Eric Piel <Eric.Piel@Bull.Net> writes:


Eric> Peter Chubb even developed a small realfeel equivalent that does
Eric> exactly that! It should work both on 2.4 and 2.5 kernels. You
Eric> can find it on the perfmon homepage and at this address:
Eric> http://www.gelato.unsw.edu.au/patches/realfeel4.c

I've also developed a microstate accounting patch that allows you to
measure the times in the interrupt handler and on the ACTIVE and
EXPIRED queues directly (and hence gives a direct measurement of
latency).  The patch was posted to LKML; and there'll be a copy on the
gelato web page ( http://www.gelato.unsw.edu.au/patches ) later today.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.
