From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 01 Dec 2004 17:57:18 +0000
Subject: Re: Out of order console initialization on HP CX2600
Message-Id: <200412011057.18519.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7077.1101898955@ocs3.ocs.com.au>
In-Reply-To: <7077.1101898955@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 01 December 2004 4:02 am, Keith Owens wrote:
> This problem has been reported against the SLES9 SP1 Beta3 ia64 debug
> kernel on HP CX2600.  The ttySn ports are detected long after
> console_init() has run, kdb detects no console and shuts down.
> 
> Why do the ttySn ports get detected after console_init() on HP?

In general, all ttyS ports are detected when the serial driver
initializes, which is long after console_init() and kdb_init().

Prior to 2.6.10, there are two exceptions:
    - if firmware supplies an HCDP, the first port listed there
      is registered as ttyS0
    - if firmware does NOT supply an HCDP, legacy COM ports at
      0x3f8 and 0x2f8 are registered as ttyS0 and ttyS1 (non-SGI
   boxes only)

> Is there anything that can be done to detect ttySn before
> console_init()?

No, there's no way to know what device will become ttySn until
the serial driver initializes.

But in current BK, there's an "early UART" console that we should
be able to adapt for kdb.  See these for details:

    http://linux.bkbits.net:8080/linux-2.5/cset%40419e7976lKL307BWDefUk52e_RkhKA
    http://linux.bkbits.net:8080/linux-2.5/cset%40419e7984hO_qp9Y7IYUlkYpTm52zFg

The early UART stuff is currently output-only, and I suppose kdb
will want to do input as well, but that seems possible to add.

> <4>Kernel command line: BOOT_IMAGE=scsi1:\efi\SuSE\vmlinuz-2.6.5-7.118-debug root=/dev/sda4 console=ttyS1,9600n8 ro
> <3>kdb: Initialization failed - no console.  kdb is disabled.
> <4>kdb version 4.4 by Keith Owens, Scott Lurndal. Copyright SGI, All Rights Reserved
> <4>ttyS0 at MMIO 0xf4050000 (irq = 49) is a 16550A
> <4>ttyS1 at MMIO 0xff5e0000 (irq = 59) is a 16550A
> <4>ttyS2 at MMIO 0xff5e2000 (irq = 60) is a 16550A
> <4>ttyS3 at MMIO 0xf4051000 (irq = 49) is a 16550A

Can you use "console=ttyS0" instead of ttyS1?
