From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 29 Mar 2007 23:54:47 +0000
Subject: RE: [patch 0/5] ia64 memory attribute fixes
Message-Id: <617E1C2C70743745A92448908E030B2A014BEB3B@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703211616.17257.bjorn.helgaas@hp.com>
In-Reply-To: <200703211616.17257.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Found a small problem.  With this patch in place I get
a complaint while booting on an Intel tiger:

Trying to vfree() bad address (a00000020001b000)
BUG: at vm/vmalloc.c:323 __vunmap()

The stack trace points back to drivers/firmware/dmi_scan.c
in dmi_table()

	buf = dmi_ioremap(base, len);
		...
	dmi_iounmap(buf, len);

Before applying your patch we have base=0x7fefb000 len=0xfbc
and the return value is 0xc00000007fefb000

After your patch, we get buf = 0xa00000020001b000

-Tony
