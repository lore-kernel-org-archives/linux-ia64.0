From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 09 Jul 2003 22:17:42 +0000
Subject: Re: clone testcases in LTP
Message-Id: <marc-linux-ia64-105778922629258@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105778639326638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105778639326638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 9 Jul 2003 16:32:59 -0500, Nathan Straz <nstraz@sgi.com> said:

  Nathan> Could someone in the Linux ia64 community look at the clone
  Nathan> system call tests that the LTP has under
  Nathan> ltp/testcases/kernel/syscalls/clone?  I know that ia64 uses
  Nathan> clone2() instead of clone() but I don't know where the
  Nathan> differences are documented.  I would like to get these test
  Nathan> cases, or some variation or them, compiling and running on
  Nathan> ia64.

The only difference between clone() and clone2() is the explicit
stack-size argument.  clone2() is discussed in detail in my book, but
if you're already familiar with clone(), it's easy to understand
what's going on.  Here is the pseudo prototype (from glibc):

/* int  __clone2(int (*fn) (void *arg), void *child_stack_base,		*/
/*	         size_t child_stack_size, int flags, void *arg,		*/
/*	         pid_t *parent_tid, void *tls, pid_t *child_tid)	*/

	--david
