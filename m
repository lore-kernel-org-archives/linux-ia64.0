From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 15 Jun 2004 04:25:36 +0000
Subject: RE: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01727AD7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>There are similer problems
>(The condition of the loop termination depends on &init_task).
>- do_each_process() macro       ... in include/linux/sched.h
>- is_devfsd_or_child() function ... in fs/devfs/base.c
>- get_tgid_list() function      ... in fs/proc/base.c

Grepping through the kernel shows nine places where
generic code is using "&init_task".  (Way up from the
one that existed when the kernel relocation patch was
first dreamed of :-( )  An no guarantee that people won't
add more.

Your option 2 is looking like the best choice.

-Tony
