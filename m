From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 07 Apr 2003 21:09:24 +0000
Subject: Re: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705426@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 3 Apr 2003 23:51:04 -0500, Jes Sorensen <jes@wildopensource.com> said:

  Jes> Hi, I have been tracing a problem with tty->count hitting an
  Jes> unidenfied state and I am starting to ponder if our current
  Jes> spin_unlock() implementation is sufficient.

  Jes> Currently the spin_unlock() implementation looks like this:

  Jes> #define spin_unlock(x) do { barrier(); ((spinlock_t *) x)->lock
  Jes> = 0;} while (0)

  Jes> barrier() doesn't guarantee memory ordering, in other words, we
  Jes> are not guaranteed that writes have been flushed to physical
  Jes> memory on exit.

Note that "lock" is declared as "volatile", so clearing it will use
"release" semantics.  (Since I know you have a copy of the ia64 linux
kernel book: this is described in detail starting on page 302).

	--david

