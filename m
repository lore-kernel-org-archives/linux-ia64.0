From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 14 Mar 2005 22:06:09 +0000
Subject: bad pgd/pmd in latest BK on ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F031272AF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux kernel <linux-kernel@vger.kernel.org>
Cc: linux-ia64@vger.kernel.org

Trying to boot a build of the latest BK on ia64 I see
a series of messages like this:

mm/memory.c:99: bad pgd e0000001feba4000.
mm/memory.c:99: bad pgd e0000001febac000.
mm/memory.c:99: bad pgd e0000001febc0d10.
mm/memory.c:105: bad pmd f000eef3f0000200.
mm/memory.c:105: bad pmd f000eef3f000e2c3.
mm/memory.c:105: bad pmd f000ff54f000eef3.
mm/memory.c:105: bad pmd f000292cf0002984.

before the kernel gets an OOPS on a deref NULL
at resched_task+0x41/0x1a0.

2.6.11-bk9 boots ok, so this was added recently.

-Tony
