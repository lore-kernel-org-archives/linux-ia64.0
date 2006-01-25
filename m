From: Grant Grundler <iod00d@hp.com>
Date: Wed, 25 Jan 2006 20:59:07 +0000
Subject: Re: [PATCH 3/6] C-language equivalents of include/asm-*/bitops.h
Message-Id: <20060125205907.GF9995@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113206.GD18584@miraclelinux.com> <20060125200250.GA26443@flint.arm.linux.org.uk>
In-Reply-To: <20060125200250.GA26443@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>
Cc: Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, Jan 25, 2006 at 08:02:50PM +0000, Russell King wrote:
> I've not really looked at the rest because I haven't figured out which
> bits will be used on ARM and which won't - which I think is another
> problem with this patch set.  I'll look again later tonight.

Russell,
I have the same problem. This file is 920 lines long and contains
7 distinct changes according to the (well written) notes.

Akinobu,
I appreciate your work - but could this particular peice be
split up into 7 chunks?

That would make checking the behavior of something like
HAVE_ARCH_FFZ_BITOPS easier for each arch.

thanks,
grant
