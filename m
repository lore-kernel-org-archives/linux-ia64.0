From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 02 Jun 2005 20:28:21 +0000
Subject: Re: fsys_rt_sigprocmask fastcall missing PF_FREEZE handling?
Message-Id: <Pine.LNX.4.62.0506021325100.20024@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506021236020.19721@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506021236020.19721@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2 Jun 2005, David Mosberger wrote:

> >>>>> On Thu, 2 Jun 2005 12:43:59 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:
> 
>   Christoph> I just compared fsys_rt_sigprocmask in
>   Christoph> arch/ia64/kernel/fsys.S with kernel/signal.c and noted
>   Christoph> that there does not seem to be any handling of the
>   Christoph> PF_FREEZE flag. This may be okay if IA64 does not support
>   Christoph> power management but I see some adaptec drivers in SLES9
>   Christoph> that use PF_FREEZE.
> 
> What tree are you looking at?  mm?  I don't see PF_FREEZE in Linus' tree.

I was looking at mm and Sles 9.

PF_FREEZE is in all trees. But the check for PF_FREEZE is missing from 
racalc_sigpending_tsk in Linus tree it seems.
