From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 17 Aug 2000 18:34:16 +0000
Subject: Re: [Linux-ia64] building glibc
Message-Id: <marc-linux-ia64-105590678205348@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 17 Aug 2000 00:26:58 -0700, Uros Prestor <uros@turbolinux.com> said:

  Uros> I saw this when building glibc on 2.4.0-test1 kernels when
  Uros> IA-64 patch introduced new stat/fstat/lstat interfaces.  You
  Uros> need an extra patch (included below courtesy of David M) which
  Uros> solves the problem.

Yes, that should fix the problem.  We should also update the simulator
to support the new system calls.  I'll put it on my todo list.

	--david

