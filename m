From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 30 Jun 2004 00:52:50 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <16610.3810.360053.664910@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Peter,

Can you feed this directly to the respective maintainer?  I want to
get 2.6.7 to work properly before moving on to newer things (and going
on vacation first... ;-).

Thanks,

	--david

>>>>> On Wed, 30 Jun 2004 10:44:10 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
  David> Hi Linus, please do a

  David> bk pull http://lia64.bkbits.net/to-linus-2.5

  David> This will update the files shown below.

  Peter> David, even after doing this I see CC drivers/firmware/pcdp.o
  Peter> /home/peterc/kernels/linux-2.6-preempt-davidm/drivers/firmware/pcdp.c:
  Peter> In function `setup_serial_console':
  Peter> /home/peterc/kernels/linux-2.6-preempt-davidm/drivers/firmware/pcdp.c:67:
  Peter> warning: implicit declaration of function `ioremap'
  Peter> /home/peterc/kernels/linux-2.6-preempt-davidm/drivers/firmware/pcdp.c:67:
  Peter> warning: assignment makes pointer from integer without a cast

  Peter> ...

  Peter> drivers/built-in.o(.init.text+0x11262): In function
  Peter> `setup_serial_console': : undefined reference to `ioremap'

  Peter> when building for ZX1.

  Peter> I found I needed this patch:


  Peter> Index: linux-2.6-preempt-davidm/drivers/firmware/pcdp.c
  Peter> =================================  Peter> --- linux-2.6-preempt-davidm.orig/drivers/firmware/pcdp.c +++
  Peter> linux-2.6-preempt-davidm/drivers/firmware/pcdp.c @@ -14,6
  Peter> +14,7 @@ #include <linux/serial.h> #include
  Peter> <linux/serial_core.h> #include <asm/serial.h> +#include
  Peter> <asm/io.h> #include "pcdp.h"
 
  Peter>  static inline int
