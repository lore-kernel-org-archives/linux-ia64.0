From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 09 Jul 2002 15:12:02 +0000
Subject: Re: [Linux-ia64] [patch] kdb-v2.1-2.4.18-ia64-usb-keyboard
Message-Id: <marc-linux-ia64-105590701905744@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905735@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905735@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 9 Jul 2002 13:40:00 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> On Mon, Jul 08, 2002 at 11:31:04AM -0700, David Mosberger
  Matthew> wrote:
  >> The hp zx1-based machines are legacy-free, so there is no
  >> old-fashion serial port.  Instead, the serial ports can be found
  >> via ACPI.  In the current machines, they're in memory-mapped I/O
  >> space.  I have a kdb patch to support this and will send it out
  >> soon (it needs a bit of cleaning up).

  Matthew> Using the HCDP table, I hope?  Not all the zx1-based
  Matthew> machines have serial ports in the ACPI namespace.

It shouldn't matter.  The kdb code doesn't know where the info comes
from.  The necessary info just gets stowed away when the serial driver
initializes.  Having said that, the firmware I tested it with doesn't
have the HCDP tables, so it might be good to verify that such configs
really do work as well.

	--david

