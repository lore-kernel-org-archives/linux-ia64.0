From: "Broadfoot, KenX" <kenx.broadfoot@intel.com>
Date: Fri, 27 Oct 2000 16:26:28 +0000
Subject: [Linux-ia64] Common kernel paging error I get
Message-Id: <marc-linux-ia64-105590678205637@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just wondering if you all see this error often:

Unable to handle kernel paging request at virtual address 0000000000000008

I am using 2.4.0-test9 patched + kdb

When this happens I can't even get into the debugger.

This is on a Quad Lion with 2 gigs of Ram

I see this mostly when running fairly heavy network traffic.


If anyone is familiar with this and has found a way to minimize it, or can
explain what it is to me I would appreciate it.

--ken broadfoot


