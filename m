From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 10 Nov 2003 16:16:44 +0000
Subject: RE: problem in booting HP zx6000 with stock kernel 2.5.75
Message-Id: <marc-linux-ia64-106848176121493@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106840426422921@msgid-missing>
In-Reply-To: <marc-linux-ia64-106840426422921@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2003-11-09 at 22:28, Deepak Kumar Gupta, Noida wrote:

> In my case after uncompressing the kernel, it just hangs. Even the SCSI disk
> driver is not loaded, so i guess problem is some where else. I am using
> Symbios (SYM53C8XX) driver. 
> 

Deepak,

   As David mentioned, 2.5.75 is rather old.  Please try 2.6.0-test9 and
start with one of the configs David pointed at on the Gelato URL.  If
you're using a VGA console, it's easy to configure the kernel to not get
output where you want it.  If you're trying to use a serial console,
make sure you're appending a 'console=ttyS0,<speed>n8' to your elilo
entry.  Note that it depends how you have your firmware setup as to
whether ttyS0 is the builtin UART port or the 'console' port on the
management port (if you have one).  You can check this in the EFI boot
option maintenance menu.  Choose one, and only one, UART port for the
console output device.  The PNP0501 entry is the builtin UART, the
HWP0002 is the management  port.  Also, the on-board scsi controller for
the zx6000 is the mpt fusion driver, not the sym driver.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

