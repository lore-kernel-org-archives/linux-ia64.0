From: Horms <horms@verge.net.au>
Date: Thu, 19 Jul 2007 07:41:49 +0000
Subject: Regression in serial console on ia64 after 2.6.22
Message-Id: <20070719074147.GA23879@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

18a8bd949d6adb311ea816125ff65050df1f3f6e appears to have caused
a regression in the serial console for ia64. I have observed the
problem on Intel Tiger2 and HP RX2620 when the console or early
cons option is specified.

For reference

Tiger2: console=uart,io,0x2f8,115200n8
RX2620: console=uart,mmio,0xff5e0000,115200n8

uart may also be uart8250, it makes no difference with regards to
this problem. console may be earlycons, that also makes no
difference as 18a8bd949d6adb311ea816125ff65050df1f3f6e handles
both options the almost the same way.

On the RX2620 a work around is to omit the console and earlycons
parameters all together, as the code in efi_setup_pcdp_console() will
autodetect the console and set it up correctly.


I believe that the problem is as follows:

After 18a8bd949d6adb311ea816125ff65050df1f3f6e, both the console
and earlycons options are handled by early_param, using the callback
setup_early_serial8250_console().

On ia64, for the hardware that I am observing this problem on
(HP RX2620 and Intel Tiger2), I believe that I am seeing the
following calls occur.

->arch/ia64/kernel/setup.c:setup_arch()
 ->parse_early_param()
  ->setup_early_serial8250_console()    N.B callback
   ->early_serial8250_setup()
    ->init_port()
     ->serial_out()
      ->outb()
       ->__outb()
        ->platform_outb()
         ->ia64_mv.outb()

However, ia64_mv may not be set until after machvec_init() is called
by setup_arch(), which occurs after the call to parse_early_param().

The reason for this ordering is that machvec_init() may be
influenced by the machvec command line argument, which
is also handled by early_param. A chicken an egg problem.


A fairly simple work-around would be to call machvec_init earlier
and have it parse the command like itself.

Another solution would be to split up early_serial8250_setup()
or setup_early_serial8250_console() somehow, such that init_port()
is not called as part of the early_param callback, but rather later
explicitly (probably by each architecture's setup_arch()). This is
somewhat similar to the way that machvec is handled.

I'm sure there are are other good, possibly better solutions.
Hence this email.


On a related note, I think that the code in efi_setup_pcdp_console()
needs to be updated to reflect that console= and earlycons= are
basically the same thing now.

I have not investigated the effects of
18a8bd949d6adb311ea816125ff65050df1f3f6e on
sn_serial_console_early_setup()

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

