From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 30 Jul 2001 22:12:07 +0000
Subject: Re: [Linux-ia64] IA64 Linux issues
Message-Id: <marc-linux-ia64-105590693005956@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005948@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005948@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Van" = Van Maren, Kevin <kevin.vanmaren@unisys.com> writes:

Van> I'm running Caldera's 6/20/01 snapshot (modified 2.4.4 kernel) on
Van> a 4X, 8GB Lion.

Van> Under even "light" I/O load (mkfs to 2-4 disks) I get horiffic
Van> behavior -- basically what is described on this thread:
Van> http://www.cs.helsinki.fi/linux/linux-kernel/2001-20/0763.html
Van> [I/O drops down to < 300 I/Os per second (vmstat), but all the
Van> CPUs are pegged 99%+ system time.]

Van> That is after I first used "swiotlb240" at elilo to avoid the
Van> panic, and then hacked the qlogicfc driver (patch at bottom) and
Van> applied the latest Adaptec driver patch (6.2.0) from freebsd.org
Van> to get 39-bit DMA.  Problem occurs with 39160 & QL2200.

I'd stay away from the qlogicfc.c driver, it's got all sorts of
limitations.

Jes

