From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 11 Sep 2001 04:11:46 +0000
Subject: Re: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805168@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 5 Sep 2001 22:47:17 +0200, Christoph Hellwig <hch@ns.caldera.de> said:

  Christoph> Please take a look at include/asm-*/namei.h - we can
  Christoph> define an emulation prefix for Linux/i386
  Christoph> (e.g. /emul/linux32) and all lookups will be tried there
  Christoph> before falling back to the native FS, This appropeach is
  Christoph> already used by the MIPS and SPARC ports and by linux-abi
  Christoph> for i386.

I don't particularly like changing filenames underneath the user, but
as far as I can see, it's the most systematic way to fix absolute
naming issues.  Unless someone has serious objections to this, I'll
make this change.  As far as I can see, neither LSB nor FHS address
the issue of where to place emulation files, so I'll propose a prefix
of "/emul/ia32-linux/" as a starter.  Any objections?

(Note to Sunil: the IA-64 ABI is of no help here because we're talking
 about files that are outside the standard library search paths and
 the issue is not really limited to shared objects only.)

	--david

