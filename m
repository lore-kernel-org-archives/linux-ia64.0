From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 09 Jun 2004 21:55:07 +0000
Subject: Re: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <16583.34619.1762.899096@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 09 Jun 2004 23:40:41 +0900, Kazuto MIYOSHI <miyoshi@linux.bs1.fc.nec.co.jp> said:

  >> 2) We tried to set the current (r13) of cpu_idle to region 5
  >> address.  But it paniced and I could not grab the cause of the
  >> panic.  Is there any reason we must put init_task in region 5?

  Kazuto> Please find the attached patch to make swapper to run on
  Kazuto> region 5.  It needs extra 2 instructions in ia64_switch_to()
  Kazuto> to stop mapping of task stack if we are switching to idle,
  Kazuto> to avoid TLB entry duplication caused by kernel text/data
  Kazuto> mapping and CURRENT_STACK mapping.

  Kazuto> I believe swapper (init_task) should be consistent for its
  Kazuto> all members, not only for wait_chldexit, and the patch will
  Kazuto> solve other potential list_head/current in-consistency
  Kazuto> raised by swapper initialization, though I am not so sure if
  Kazuto> it justifies extra instructions and complication in context
  Kazuto> switch.

That is in my opinion a worse patch compared to the reinitialization
that you proposed esterday.  Tony, what's your take on this problem?

	--david
