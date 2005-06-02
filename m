From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 02 Jun 2005 20:22:14 +0000
Subject: Re: fsys_rt_sigprocmask fastcall missing PF_FREEZE handling?
Message-Id: <17055.27254.100651.133003@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506021236020.19721@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506021236020.19721@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 2 Jun 2005 12:43:59 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  Christoph> I just compared fsys_rt_sigprocmask in
  Christoph> arch/ia64/kernel/fsys.S with kernel/signal.c and noted
  Christoph> that there does not seem to be any handling of the
  Christoph> PF_FREEZE flag. This may be okay if IA64 does not support
  Christoph> power management but I see some adaptec drivers in SLES9
  Christoph> that use PF_FREEZE.

What tree are you looking at?  mm?  I don't see PF_FREEZE in Linus' tree.

	--david
