From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 17 Mar 2004 19:16:04 +0000
Subject: Re: [PATCH] current  ( was  RE: cat /proc/acpi/events bad for your system's health!)
Message-Id: <16472.41972.771024.82798@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401CBB762@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8401CBB762@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 17 Mar 2004 20:48:00 +0800, "Yu, Luming" <luming.yu@intel.com> said:

  Luming> Perhaps, gcc did something wrong with
  Luming> set_current_state(TASK_RUNNING).  Because r13 intend for
  Luming> pointer to the current task.

OK, the problem was that r13 should have been declared as a _global_
register variable in gcc_intrin.h.  This is fixed now.

Thanks,

	--david
