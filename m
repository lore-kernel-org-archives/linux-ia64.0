From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Jun 2004 05:19:28 +0000
Subject: RE: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F016C4805@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>void
>initialize_init_task (void)
>{
>	*current = (task_t) INIT_TASK((*current));
>}
>
>and then call this function from setup_arch().
>
>The code does compile but doesn't seem to work.  I suspect there are
>other lists that are inconsistent now.  Anybody want to track this
>down?

Don't you need a "ia64_tpa()" call in there someplace to convert the
region 5 address to region 7?

-Tony
