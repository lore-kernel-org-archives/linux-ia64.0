From: David Mosberger <davidm@hpl.hp.com>
Date: Sun, 15 Apr 2001 20:37:50 +0000
Subject: Re: [Linux-ia64] Linuxconf patch
Message-Id: <marc-linux-ia64-105590693005404@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005401@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005401@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 15 Apr 2001 07:05:28 +0200, Jes Sorensen <jes@linuxcare.com> said:

  Jes> Please don't inline the syscall like that. We do support
  Jes> syscall() in glibc and it would be nicer (and future
  Jes> compatible) if you use that instead.

Better still: use the libc provided stub when one is available.
glibc2.2 already defines quotactl().  I'd recommend to use autoconf to
check for quotactl() and fall back on syscall() when it doesn't exist
in libc (no need to do this for IA-64 Linux though, as glibc-2.2
already supports this).

	--david

PS: It's fine to send such patches to linux-ia64, but I'd also
    recommend to directly forward the fixes to the author/maintainer
    of the program.

