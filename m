From: Roman Hodek <roman@caldera.de>
Date: Thu, 14 Mar 2002 14:19:46 +0000
Subject: Re: [Linux-ia64] Does IDE DMA work?
Message-Id: <marc-linux-ia64-105590701905280@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905278@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905278@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Has anyone got IDE DMA working? When I try it with 2.4.18 the
> machine is hanging during partition table reading, with the disk
> light constantly on. It seems like the kernel is not receiving any
> answer from the disk.

I noticed similar problems some time ago (2.4.13 AFAICR). Our test
plan said "test with an IDE disk > 64GB", so we plugged one in and the
kernel said nothing more than "DMA timeout". But it's not necessarily
the kernel, it also could be that the IDE interface on the legacy I/O
board isn't able to do all IDE features properly. Has anybody used it
for devices other than CD-ROM and LS120?

Roman

