From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 21 Jan 2014 17:32:13 +0000
Subject: RE: Kernel compiled with gcc-4.6+ fails to boot on ia64
Message-Id: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Please assist me in acquiring more information, as there currently is no output at all on the
> serial console I am attached to (via the management console, which is set up in EFI as the
> default console, which appears in Linux as ttyS3). Usually I get output right from the start,
> so I assume that the problem must be very early in the boot process.

Did you try the ia64 early console options.  See Documentation/ia64/serial.txt ... boot argument
you need to add on a rx2600 will look something like this:

console=uart,mmio,0xff5e0000

but the hex number will be whatever you need for ttyS3 (run "dmesg | grep tty" on your
kernel that does boot to find the right value).

-Tony

