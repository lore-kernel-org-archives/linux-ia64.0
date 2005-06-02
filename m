From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 02 Jun 2005 21:21:09 +0000
Subject: Re: fsys_rt_sigprocmask fastcall missing PF_FREEZE handling?
Message-Id: <17055.30789.502210.18693@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506021236020.19721@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506021236020.19721@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 2 Jun 2005 13:28:21 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  Christoph> On Thu, 2 Jun 2005, David Mosberger wrote:

  >> >>>>> On Thu, 2 Jun 2005 12:43:59 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  Christoph> I just compared fsys_rt_sigprocmask in
  Christoph> arch/ia64/kernel/fsys.S with kernel/signal.c and noted
  Christoph> that there does not seem to be any handling of the
  Christoph> PF_FREEZE flag. This may be okay if IA64 does not support
  Christoph> power management but I see some adaptec drivers in SLES9
  Christoph> that use PF_FREEZE.

  >> What tree are you looking at?  mm?  I don't see PF_FREEZE in Linus' tree.

  Christoph> I was looking at mm and Sles 9.

  Christoph> PF_FREEZE is in all trees. But the check for PF_FREEZE is
  Christoph> missing from racalc_sigpending_tsk in Linus tree it
  Christoph> seems.

That would explain why it's missing.  Clearly you'd want the
light-weight version of sigprocmask to be consistent with the
heavy-weight version (as is the case for Linus' tree).

	--david
