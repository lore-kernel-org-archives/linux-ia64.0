From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 11 Jul 2005 23:02:42 +0000
Subject: RE: [PATCH] enable to read region 5 from /dev/kmem
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03DF2B37@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C501CD.4010907@jp.fujitsu.com>
In-Reply-To: <42C501CD.4010907@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>This patch allows users to read region 5 from /dev/kmem and 
>enhances range check of it.

I'm uneasy about this change to drivers/char/mem.c.  Won't it stop
those architectures that have memory at physical 0x0 from accessing
it?

 		ptr = xlate_dev_mem_ptr(p);
-
+		if (!ptr)
+			return -EFAULT

-Tony
