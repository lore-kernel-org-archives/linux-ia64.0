From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 24 Sep 2001 16:42:21 +0000
Subject: Re: [Linux-ia64] differentiating single-step vs taken-branch trap
Message-Id: <marc-linux-ia64-105590698805243@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805241@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805241@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Wei,

>>>>> On Sun, 23 Sep 2001 18:43:18 -0700 (PDT), Weihaw Chuang <weihaw@yahoo.com> said:

  Wei> Hi everyone, I've got two questions, but only the first is
  Wei> really important.  1. I'm using the ptrace kernel interface to
  Wei> trace a child process via single-step or taken-branch traps
  Wei> (through David Mosberger's utrace tool).  Is there a way I can
  Wei> use ptrace to allow me to single-step, and in addition observe
  Wei> occurances of taken-branches?

Yes, the siginfo trap code (si_code) will tell you.  It is set to
TRAP_BRANCH for a taken branch and to TRAP_TRACE for a single step
trap.  Use PTRACE_GETSIGINFO to get a hold of the siginfo of the
traced task.

	--david

