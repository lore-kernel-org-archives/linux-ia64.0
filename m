From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 05 Feb 2002 19:22:43 +0000
Subject: Re: [Linux-ia64] cmpxchg patch
Message-Id: <marc-linux-ia64-105590698805990@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805982@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805982@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 05 Feb 2002 01:13:47 -0600, Ray Bryant <raybry@engr.sgi.com> said:

  Ray> Also, I see that previous versions of the in-line asm spinlock
  Ray> code in IA64 used a proceudure to handle the complicated cases.

Are you referring to the "#ifdef NEW_LOCK" code?  That's supposed to
be a newer version of the spinlock code, but I haven't had time to
debug and finish it since I started working on it (probably well over
a year ago... ;-/.  I think it makes a lot of sense to handle the
contended case out of line, in a shared procedure, so you can do
back-off etc.

  Ray> However, that procedure is not part of the source tree at the
  Ray> present time.  I'm trying to do something similar to create
  Ray> NUMA aware locks that are as fast (or very nearly so) as the
  Ray> current spin locks, but have the good NUMA properties of mcs
  Ray> locks.  Any experience you have with creating spin lock code
  Ray> that calls out to a C procedure to handle the non-common cases
  Ray> would be appreciated.

The trick is to do this without forcing the "caller" to become a
non-leaf function.  I believe there are a fair number of leaf routines
which play with spinlocks and if they had to do a proper function
call, they would become non-leaf routines and this could have a
significant impact on performance.  Getting this right in the face of
potentially different compilers (and compiler versions) and kernel
unwinding is quite tricky, but it should be possible.  I'd be
interested in seeing experimentation in this area.  Like you say, the
current spinlocks are unlikely to scale well beyond moderately small
numbers of cpus.

	--david

