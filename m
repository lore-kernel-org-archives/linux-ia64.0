From: Matthew Wilcox <willy@debian.org>
Date: Tue, 09 Jul 2002 12:40:00 +0000
Subject: Re: [Linux-ia64] [patch] kdb-v2.1-2.4.18-ia64-usb-keyboard
Message-Id: <marc-linux-ia64-105590701905743@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905735@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905735@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 08, 2002 at 11:31:04AM -0700, David Mosberger wrote:
> The hp zx1-based machines are legacy-free, so there is no old-fashion
> serial port.  Instead, the serial ports can be found via ACPI.  In the
> current machines, they're in memory-mapped I/O space.  I have a kdb
> patch to support this and will send it out soon (it needs a bit of
> cleaning up).

Using the HCDP table, I hope?  Not all the zx1-based machines have serial
ports in the ACPI namespace.

-- 
Revolutions do not require corporate support.

