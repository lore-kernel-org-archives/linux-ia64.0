From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 24 Sep 2001 18:03:36 +0000
Subject: Re: [Linux-ia64] differentiating single-step vs taken-branch trap
Message-Id: <marc-linux-ia64-105590698805245@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805241@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805241@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 24 Sep 2001 10:53:29 -0700 (PDT), Weihaw Chuang <weihaw@yahoo.com> said:

  Wei> In which header file do I find the declaration/definition of
  Wei> the PTRACE_GETSIGINFO (as well as TRAP_TRACE, TRAP_BRANCH) ?
  Wei> I'm using a machine with 2.4.0 kernel.  Would this rather old
  Wei> kernel be the reason why?

It comes from <sys/ptrace.h>.  If it's not there, you need to upgrade
your glibc.  A newer kernel wouldn't hurt either, though...

	--david

