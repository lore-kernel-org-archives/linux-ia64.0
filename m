From: Bdale Garbee <bdale@gag.com>
Date: Thu, 14 Mar 2002 17:09:35 +0000
Subject: Re: [Linux-ia64] Does IDE DMA work?
Message-Id: <marc-linux-ia64-105590701905282@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905278@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905278@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

roman@caldera.de (Roman Hodek) writes:

> But it's not necessarily
> the kernel, it also could be that the IDE interface on the legacy I/O
> board isn't able to do all IDE features properly. Has anybody used it
> for devices other than CD-ROM and LS120?

I have an 80G Maxtor disk as hdc in my HP i2000 (BigSur) running Debian with 
our current 2.4.17 kernel and it works fine.  I've also replaced the provided
DVD-ROM with an HP dvd100i DVD+RW drive, which is also working ok.

Bdale

