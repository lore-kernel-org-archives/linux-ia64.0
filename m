From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 25 Jun 2007 23:45:09 +0000
Subject: RE: intercept trap when running a 32bit binary
Message-Id: <617E1C2C70743745A92448908E030B2A01C20907@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070625221349.GA25054@bsd.hu>
In-Reply-To: <20070625221349.GA25054@bsd.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I guess when i enter the chroot i use h/w to execute the shell.

If ia32-el is installed and active, then it will keep on handling the
execution even inside the chroot.

> x86 gdb is installed in the chroot, but the backtrace is not quiet
useful (for me).
> more info:

Nothing useful there for me either ... though since the crash
looks like it is happening in some constructors, it is possible
that your program has some mistaken hard-coded assumptions that
the pagesize is 4K.  But that is just a really wild guess.

-Tony
