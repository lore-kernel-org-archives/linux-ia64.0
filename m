From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 17 Apr 2002 14:54:14 +0000
Subject: [Linux-ia64] Re: PAL entry point
Message-Id: <marc-linux-ia64-105590701905468@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 17 Apr 2002 15:09:51 +0200, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Stephane, David, do you agree making the symbol
  Christian> pal_entry_point global (included in pal.S)? I would need
  Christian> access to the PAL routines directly from my program
  Christian> without using the provided functions.

I'm not sure that's a good idea.  PAL has very particular constraints
on the environment in which it can be called in.  Why aren't the
normal entry points (ia64_pal_call_static(), ia64_pal_call_stacked(),
ia64_pal_call_phys_static(), and ia64_pal_call_phys_stacked())
sufficient?

	--david

