From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 May 2004 18:33:19 +0000
Subject: Re: [PATCH]   (was RE: IA64 test report:Umount cdrom oops : 2.6.6 /Lion 2004-5-13: 8/10  pass)
Message-Id: <16555.43119.756718.750345@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F840462309C@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F840462309C@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 May 2004 21:45:31 +0800, "Yu, Luming" <luming.yu@intel.com> said:

  Luming> I added a printk after lock_kernel() at:
  Luming> lock_kernel();
  Luming> printk("do_umount: depteh = %d\n", current->lock_depth);
  Luming> DQUOT_OFF(sb);
  Luming> acct_auto_close(sb);
  Luming> unlock_kernel();

  Luming> Then the OOPs is gone, and umounting cdrom is surprisingly
  Luming> working well.

  Luming> After some investigation, I found that ,if there is no
  Luming> printk statement.  then above code should looks like:
  Luming> (Because other 2 statements are defined as blank )
  Luming> lock_kernel(); unlock_kernel();

  Luming> [snip...]

  Luming> Hmm, maybe its memory ordering issue here.

How interesting.  Do you have CONFIG_PREEMPT enabled?

	--david
