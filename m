From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 10 Oct 2001 20:26:56 +0000
Subject: RE: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805320@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Oct 2001 13:18:38 -0700, "Mallick, Asit K" <asit.k.mallick@intel.com> said:

  Asit> David/Jesse, I would like the default to be noprint. As Jack
  Asit> mentioned that there are applications that will generate lots
  Asit> of these messages. These messages are ok for development
  Asit> systems and debugging applications but for production systems
  Asit> this creates problem. Most of the users want to run the
  Asit> applications (production) that do not require changing the
  Asit> configuration.

It's fine by me if distributors set things up such that they're
disabled by default, but for the kernel I'm releasing, I'll keep them
turned on.  It's just too easy to forget about them otherwise.  And a
program that accidentally generates tons of unaligned faults or fpswa
faults will perform *a lot* worse than a program that occasionally
generates a log message.

  Asit> We have seen people running applications on top of Linux and
  Asit> complaining about the performance compared to other OSes. The
  Asit> performance difference is due to the logging of these
  Asit> messages.

Can you be more specific?  A machine should easily tolerate a rate of
one logged message per second, so if this makes a significant
performance difference, that would be strange.

	--david

