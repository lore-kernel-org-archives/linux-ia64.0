From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Jul 2002 18:31:04 +0000
Subject: Re: [Linux-ia64] [patch] kdb-v2.1-2.4.18-ia64-usb-keyboard
Message-Id: <marc-linux-ia64-105590701905739@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905735@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905735@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 04 Jul 2002 10:03:50 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> Sebastien Lelarge <Sebastien.Lelarge@bull.net> writes:

  Sebastien> Notice that you won't be able to use your USB Keyboard
  Sebastien> before USB is started. But it's a solution to
  Sebastien> debug a system running.

  Andreas> Another solution is to use a serial console.

The hp zx1-based machines are legacy-free, so there is no old-fashion
serial port.  Instead, the serial ports can be found via ACPI.  In the
current machines, they're in memory-mapped I/O space.  I have a kdb
patch to support this and will send it out soon (it needs a bit of
cleaning up).

	--david

