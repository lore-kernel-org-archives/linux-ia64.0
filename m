From: Pete Wyckoff <pw@osc.edu>
Date: Mon, 13 Nov 2000 19:06:45 +0000
Subject: [Linux-ia64] kdb-2.4-test10 ia64
Message-Id: <marc-linux-ia64-105590678205690@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You may want to run through include/linux/kdb.h and kdb/kdb_bp.h and
finish the conversion from __SMP__ to CONFIG_SMP.  It doesn't look
like much is affected currently without that change, though (bpa).

		-- Pete

