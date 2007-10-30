From: David Miller <davem@davemloft.net>
Date: Tue, 30 Oct 2007 07:36:22 +0000
Subject: Re: [PATCH] fix typo in per_cpu_offset
Message-Id: <20071030.003622.265888160.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0710230015x1640388aod98cae2fa3fc82c2@mail.gmail.com>
	<20071030071513.GE5361@verge.net.au>
In-Reply-To: <20071030071513.GE5361@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: luming.yu@gmail.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Tue, 30 Oct 2007 16:15:13 +0900

> Though curiuously with my config nothing uses per_cpu_offset()
> (I added a bogus call to produce an error.) Is it actually
> used on ia64?

It is unused, and in that regard should probably be deleted.

include/asm-generic/percpu.h defines a seemingly similarly
unused per_cpu_offset() macro define as well
