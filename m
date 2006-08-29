From: Ralf Baechle <ralf@linux-mips.org>
Date: Tue, 29 Aug 2006 16:17:48 +0000
Subject: Re: [CFT:PATCH] Removing possible wrong asm/serial.h inclusions
Message-Id: <20060829161748.GF29289@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060828085244.GA13544@flint.arm.linux.org.uk>
In-Reply-To: <20060828085244.GA13544@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-embedded@ozlabs.org, paulkf@microgate.com, takata@linux-m32r.org, linux-kernel@vger.kernel.org

On Mon, Aug 28, 2006 at 09:52:44AM +0100, Russell King wrote:

> asm/serial.h is supposed to contain the definitions for the architecture
> specific 8250 ports for the 8250 driver.  It may also define BASE_BAUD,
> but this is the base baud for the architecture specific ports _only_.
> 
> Therefore, nothing other than the 8250 driver should be including this
> header file.  In order to move towards this goal, here is a patch which
> removes some of the more obvious incorrect includes of the file.
> 
> MIPS and PPC has rather a lot of stuff in asm/serial.h, some of it looks
> related to non-8250 ports.  Hence, it's not trivial to conclude that
> these includes are indeed unnecessary, so can mips and ppc people please
> test this patch carefully.

The MIPS bits were just unused leftovers from the days when the arch
code did did register serials & consoles.  So for the MIPS bits:

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
