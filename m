From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 07 Dec 2000 00:58:24 +0000
Subject: Re: [Linux-ia64] TurboLinux IA-64 Beta 2 (2000-11-23) Available for download
Message-Id: <marc-linux-ia64-105590678205803@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205769@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205769@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Dec 2000 16:48:22 -0800, Don Dugger <n0ano@tlaloc.n0ano.com> said:

  Don> Michael- I tried to re-compile X on this release and came
  Don> across a problem.  The include file `/usr/include/asm/io.h'
  Don> defines the in/out functions in terms of new `platform_*'
  Don> functions, which are not defined for user programs.  Do you
  Don> know where these `platform_*' functions are supposed to be
  Don> defined?

Why is X including asm/io.h when we have sys/io.h?

At the risk of repeating myself: applications that include kernel
headers are broken.  Period.

	--david

