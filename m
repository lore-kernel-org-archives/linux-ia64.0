From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Dec 2004 01:22:27 +0000
Subject: Re: [patch 2.6.10-rc3] Add TIF_SIGDELAYED processing
Message-Id: <16823.43219.609251.549622@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <15449.1102482344@kao1.melbourne.sgi.com>
In-Reply-To: <15449.1102482344@kao1.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 08 Dec 2004 16:05:44 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Some of the work on recoverable MCA events has a requirement
  Keith> to send a signal to a user process.  But it is not safe to
  Keith> send signals from MCA/INIT/NMI/PMI, because the rest of the
  Keith> kernel is an unknown state.  This patch adds set_sigdelayed()
  Keith> which is called from the problem contexts to set the delayed
  Keith> signal.  The delayed signal will be delivered from the right
  Keith> context on the next transition from kernel to user space.

  Keith> If TIF_SIGDELAYED is set when we run ia64_leave_kernel or
  Keith> ia64_leave_syscall then the delayed signal is delivered and
  Keith> cleared.  All code for sigdelayed processing is on the slow
  Keith> paths.

  Keith> A recoverable MCA handler that wants to kill a user task just
  Keith> does

  Keith>   set_sigdelayed(pid, signo, code, addr);

It seems rather dangerous to stash away PIDs and deliver signals to
them later on.  It's just an invitation for races, IMHO.

	--david
