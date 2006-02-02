From: Jack Steiner <steiner@sgi.com>
Date: Thu, 02 Feb 2006 20:44:22 +0000
Subject: ia64 printk_clock()
Message-Id: <20060202204422.GA27082@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We are seeing kernel hangs in early boot if CONFIG_PRINTK_TIME is
enabled. The hang is caused by a reference in sched_clock() to 
the percpu data area before it is initialized. 

I know there was discussion about this late last summer & I thought
Tony posted a patch. Does anyone recall the status.

AFAICT, we see failures on SN systems but other IA64 systems work ok.

---
Jack
