From: Luis Chamberlain <mcgrof@kernel.org>
Date: Fri, 26 May 2023 21:59:14 +0000
Subject: Re: Boot regression in Linux v6.4-rc3
Message-Id: <ZHErssbUSbSznTVA@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
In-Reply-To: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 26, 2023 at 12:55:14PM +0200, Frank Scheiner wrote:
> Dear all,
> 
> there is a boot regression in effect in Linux v6.4-rc3 that affects at
> least:
> 
> * rx2620 (w/2 x Montecito and zx1)
> * rx2800-i2 (w/1 x Tukwila)

Jesus, ia64 is even dropped from qemu as of 2.11. We're now around qemu
7.11 to give some perspective. I'm just wondering how to reproduce
testing easily instead of this ping pong back and forth for this
architecture for some oddball architectures.

Through commit 96ec72a3425d1 ("ia64: Mark architecture as orphaned")
it was noted even the old maintainer no longer had access to working
machines and so it was orphan'd.

Not saying that debugging commit ac3b4328392344 ("module: replace
module_layout with module_memory") is going to be impossible, quite
the contrary I think it would be good to root cause it, if possible,
as perhaps it may also be similar to some other future oddball arch
bug later that may come up.

But certainly just trying to see what options we have to test this
architecture.

And what's the status of removal for ia64 anyway?

  Luis
