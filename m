From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sun, 23 Jun 2002 06:18:13 +0000
Subject: Re: [Linux-ia64] /usr/lib/gcrt1.o on RH 7.2
Message-Id: <marc-linux-ia64-105590701905713@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905700@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905700@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 22 Jun 2002 23:11:47 -0700, Randolph Chung <randolph@tausq.org> said:

  Randolph> At least on Debian, if the application is linked against
  Randolph> pthread then compiling with profiling does not work. The
  Randolph> resulting binary will die with a SIGILL on startup. You
  Randolph> don't need to actually call any pthread functions, just
  Randolph> linking pthread is enough.

Even if it's statically linked?  Dynamically linked binaries do not
work with gprof.  I wasn't aware of any pthread-specific issues.

	--david

