From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Mar 2003 23:32:52 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590723705344@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 28 Mar 2003 10:15:02 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> The code does not rely on any implementation specific
  Keith> behaviour.  Stating that ar.pfs is zero is well defined, it
  Keith> means that the caller (rp in r28) of this code has no frame.

No, an unwinder might check whether a stacked register is out of the
current frame and complain if so.  Ergo, it's implementation-dependent
behavior.

  >> Can you start this discussion?

  Keith> I can start it, but it will take months to get agreement on
  Keith> the change to the unwind spec, followed by more time for the
  Keith> ia64 assemblers to be upgraded to handle the new unwind
  Keith> descriptor and more time for users to upgrade to the new
  Keith> binutils before the kernel can use any new construct.  I want
  Keith> to get debugging working for hung ia64 spinlocks this month,
  Keith> not in a year's time.

We don't have to wait until all the details are settled.  What's
important is that there is a general agreement that the code in
question needs to be accommodated.

  Keith> David, you added the NEW_LOCK code even though it never
  Keith> worked and could never work.  But when I supply code that
  Keith> works, is faster, allows for better debugging and performance
  Keith> monitoring you quibble about one construct to get the unwind
  Keith> data right.  I do not understand your priorities here.

Want to guess why the NEW_LOCK code was never enabled?  If you want to
add the code with an #if 0, that's fine with me.

	--david


