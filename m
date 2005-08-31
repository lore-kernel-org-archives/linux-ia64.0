From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 31 Aug 2005 21:13:43 +0000
Subject: RE: [PATCH] Reserve syscall number for sys_migrate_pages
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04472B19@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508311347470.29108@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>+#define __NR_sys_migrate_pages		1280

The tradition is to leave out-of-tree patches to step to
a new number when new syscalls usurp the one they thought
they were going to get.

New syscalls are not added very often, so this isn't really
much effort (compared with maintaining all the code to implement
the new syscall).

-Tony
