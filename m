From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 Jul 2007 23:39:58 +0000
Subject: RE: "Add support for vector domain" breaks boot on x355
Message-Id: <617E1C2C70743745A92448908E030B2A020E4195@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070731221356.GA31324@us.ibm.com>
In-Reply-To: <20070731221356.GA31324@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trimmed limux-kernel and Linus from the Cc list ... this looks like
an ia64 only issue at the moment.

> Hangs hard after
>
> ELILO boot: Uncompressing Linux...done
> Loading file
> \EFI\debian\boot\initrd-autobench.img...done

Ouch.  That isn't far at all.  Are you using a serial console with
a console=uart,io,0xxxx or console=uart,mmio,0xxxx to get the
console up and running at the earliest point in the boot process?
[It looks like the answer is "no" from the console log you attached].
If not, please try this (you can figure out the magic arguments by
running "dmesg | grep tty" after a normal boot, and looking at
Documentation/ia64/serial.txt).  Looks like "uart,io,0x3f8" will
be the right magic for you.

There are a couple of small extra patches from Kaneshige-san that
aren't in Linus' tree yet.  I just pushed them up to kernel.org so
they should show up in my git tree there in the next few minutes.

 git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

So you might want to try with those patches included in case this
has already been fixed.

-Tony
