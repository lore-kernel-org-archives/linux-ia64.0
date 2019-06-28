From: Frank Scheiner <frank.scheiner@web.de>
Date: Fri, 28 Jun 2019 07:35:25 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <6ecf5f63-6b77-2836-79ee-258438ba4bd0@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 6/28/19 08:26, Christoph Hellwig wrote:
> Btw, as a workaround you could try to disable CONFIG_NUMA in
> your .config - as far as I can tell the rx2800 i2 is not actually
> a NUMA system.

Actually I think it is a NUMA system. Maybe it's not acting like one in
my configuration, as I only have a single processor installed. But the
Tukwila has its memory controller integrated into the processor and
interconnects with other processors or chipset components via QPI like
the Nehalem. This can be compared to Opterons and HyperTransport.

Cheers,
Frank
