From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 02 Jan 2002 23:06:19 +0000
Subject: Re: [Linux-ia64] [PATCH][RFC][CFT] remove global errno from the kernel, make _syscallX kernel-only
Message-Id: <marc-linux-ia64-105590698805727@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 30 Dec 2001 22:05:00 -0500, Lennert Buytenhek <buytenh@gnu.org> said:

  Lennert> What I would like to know from each architecture team: -
  Lennert> What is your arch's policy on userspace usage of
  Lennert> asm/unistd.h, and consequently, what is your opinion on the
  Lennert> goal these patches aim for?  - Are the changes I made in
  Lennert> [1] and [2] for your $arch technically correct?  Please CC
  Lennert> me on replies as I'm not on any of the lists posted to.

  Lennert> My intention is to push these to Linus for 2.5 if everyone
  Lennert> agrees.  They're probably too intrusive for 2.4 (although
  Lennert> I'd love people to convince me otherwise).

The patch looks good to me as far as IA-64 Linux is concerned.  The
syscall() macros exported by asm-ia64/unistd.h were never supported in
user level.

Thanks,

	--david

