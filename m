From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 12 Aug 2004 09:17:08 +0000
Subject: Re: Altix I/O code reorganization - 6 of 21
Message-Id: <20040812101708.D5988@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408112327.i7BNRb5w163586@fsgi900.americas.sgi.com>
In-Reply-To: <200408112327.i7BNRb5w163586@fsgi900.americas.sgi.com>; from pfg@sgi.com on Wed, Aug 11, 2004 at 06:27:37PM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hch@infradead.org

On Wed, Aug 11, 2004 at 06:27:37PM -0500, Pat Gefre wrote:
> 2 additional SAL calls were added.  This SAL call multiplexes 
> into 10 different calls inside of Prom:

Which makes it less non-standard?

> Eventhough, we live within the arch/ia64, our IO Chipsets are definitely not 
> anything close to every other arch/ia64 platforms.

Please look a little closer at the HP zx1 :)

> What PPB code in the Linux kernel are you commenting on?

Spread drivers/pci/*.  Didn't it ever happen to you that Pci to PCI bridges
just work on any other linux plattform?

