From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Nov 2001 21:20:12 +0000
Subject: [Linux-ia64] resend: gcc NaT bug
Message-Id: <marc-linux-ia64-105590698805539@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm resending this message from Jim here because I think it's of
general interest (and the original submission bounced due to temporary
mailer problems at HP Labs).

Jim says he has no plans to backport the changes to earlier versions
of the compiler, but I'd of course encourage distributors to ensure
that the compiler they ship has this important problem fixed.

	--david

Subject: Re: gcc compiler bug 
Date: Mon, 19 Nov 2001 23:13:21 -0800
From: Jim Wilson <wilson@cygnus.com>

This is in response to an earlier thread.

Andrew MacLeod has written two gcc patches to fix NaT related problems
originally reported in this thread.

One patch is substantially the same as the patch Steve Ellcey wrote.  This
fixes the testcase in his FSF gcc PR target/2246.  See 
http://gcc.gnu.org/ml/gcc-bugs/2001-11/msg00501.html
This patch only handles the specific case where a structure is being returned.
It doesn't fix the general case.

The second patch is more general, and does what I have suggested before.
It uses dataflow info to find registers whose first set is a partial register
set, and then clears the entire register before the set.  This makes sure that
the NaT bit is clear before we use the register.  See
http://gcc.gnu.org/ml/gcc-bugs/2001-11/msg00500.html
This fixes the testcase Sunil posted.  The extra register clear is emitted
before the combine optimization pass, so we are able to optimize away the
extra set in some cases.

Both patches have been approved for gcc 3.1, but neither one has been checked
in yet.  The first patch is safe, but the second one is a little risky.

Jim

