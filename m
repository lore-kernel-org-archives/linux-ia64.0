From: "Zach, Yoav" <yoav.zach@intel.com>
Date: Mon, 22 Apr 2002 07:02:52 +0000
Subject: RE: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905487@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest patch adds the '-g' switch to the main Makefile. When doing
'make', the size of the resulted binary is ~55M. Without the '-g', its size
is ~8M. Was this switch added as a workaround for some problem, or can it be
removed safely ?

Thanks,
Yoav.

-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Thursday, April 11, 2002 0:42 AM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] new kernel patch (relative to 2.4.18)


The latest ia64 patch relative to 2.4.18 is now available
at ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/
in file:

	linux-2.4.18-ia64-020410.diff.gz


