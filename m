From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Aug 2003 16:34:42 +0000
Subject: RE: kernel update (relative to 2.6.0-test4)
Message-Id: <marc-linux-ia64-106200240214008@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106192276030286@msgid-missing>
In-Reply-To: <marc-linux-ia64-106192276030286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Tony> Any clues on what the warning from OBJCOPY really means?
> 
> Nope.  I don't get that (building for zx1):


Ok, I found it.  I somehow ended up with CONFIG_PM=y, so "kernel/power"
got built, and inside kernel/power/main.c there is:

  static int in_suspend __nosavedata = 0;

where __nosavedata is defined in include/linux/init.h as:

#define __nosavedata __attribute__ ((__section__ (".data.nosave")))

We don't have an entry in vmlinux.lds.S to handle this section.

-Tony
