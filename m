From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 23 Feb 2000 00:40:24 +0000
Subject: RE: [Linux-ia64] ILP32 support?
Message-Id: <marc-linux-ia64-105590678204961@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204954@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204954@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 22 Feb 2000 16:11:53 -0800, "Vadim Furman" <vadimf@mainsoft.com> said:

  Vadim> IMHO benefits of ILP32 are huge, since you can relatively
  Vadim> simply port existing 32 apps to ia64 and in the same time
  Vadim> enjoy the perfomance of the new chip.

If it's not a performance critical program, you might just as well
leave it an x86 binary and do no porting at all.  If it's a
performance critical program, then it's probably worthwhile to make it
64-bit clean (which isn't hard) and get the benefit of wide arithmetic
and assurance that the program can deal with 64-bit files, address
spaces, and y2038 without any problem at all.

  Vadim> Is it possible to force LP64 processes below 4G? Is there a
  Vadim> compiler/linker switch to do so?

You can use a linker script to force things below 4GB.  For mmap,
you'd need to change the kernel to push the mmap base below 4GB.
You'll be on your own though if you do this.  All open source programs
I know of are 64-bit clean so the incentive for the open source
community to support ILP32 is very small.

	--david


