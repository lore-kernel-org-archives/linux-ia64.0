From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 17 Sep 2001 20:33:11 +0000
Subject: Re: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805195@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 10 Sep 2001 21:11:46 -0700, David Mosberger <davidm@hpl.hp.com> said:

>>>>> On Wed, 5 Sep 2001 22:47:17 +0200, Christoph Hellwig <hch@ns.caldera.de> said:
  Christoph> Please take a look at include/asm-*/namei.h - we can
  Christoph> define an emulation prefix for Linux/i386
  Christoph> (e.g. /emul/linux32) and all lookups will be tried there
  Christoph> before falling back to the native FS, This appropeach is
  Christoph> already used by the MIPS and SPARC ports and by linux-abi
  Christoph> for i386.

  David> I don't particularly like changing filenames underneath the
  David> user, but as far as I can see, it's the most systematic way
  David> to fix absolute naming issues.  Unless someone has serious
  David> objections to this, I'll make this change.  As far as I can
  David> see, neither LSB nor FHS address the issue of where to place
  David> emulation files, so I'll propose a prefix of
  David> "/emul/ia32-linux/" as a starter.  Any objections?

Getting this to work required a little more than just changing
namei.h, but nothing difficult.  In any case, I have this tested now
and it does the job.  In case you're not familiar with how the
emulation prefix works: for any IA-32 binary, absolute filename
lookups will now start in /emul/ia32-linux/.  If the desired file is
found there, it will be used and otherwise the kernel will try to open
the same filename without the prefix.

It seems to me it would make sense if the distributors would retire
using /usr/i386-*-linux and switch over to /emul/ia32-linux instead.
Also, it should be possible to move /lib/ld-linux.so* etc. to
/emul/ia32-linux/lib.

	--david

