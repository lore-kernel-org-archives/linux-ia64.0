From: Christoph Hellwig <hch@lst.de>
Date: Tue, 25 Jun 2019 08:18:25 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <20190625081825.GA31752@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 25, 2019 at 10:16:22AM +0200, Frank Scheiner wrote:
> Looks like this patch is not enough or not related, a kernel v5.1.15
> with that patch applied yields the following:

Can you use gdb to disassemle the faulting addresss?

Something like:

gdb vmlinux

The in gdb:

l *(__alloc_pages_nodemask+0x281)
