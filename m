From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jul 2003 16:25:06 +0000
Subject: Re: clone testcases in LTP
Message-Id: <marc-linux-ia64-105785448417692@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105778639326638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105778639326638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 10 Jul 2003 11:18:38 -0500, Nathan Straz <nstraz@sgi.com> said:

  >> /* int __clone2(int (*fn) (void *arg), void *child_stack_base, */
  >> /* size_t child_stack_size, int flags, void *arg, */ /* pid_t
  >> *parent_tid, void *tls, pid_t *child_tid) */

  Nathan> Hmm, that prototype seems to have a lot more args than the
  Nathan> clone man page states:

  Nathan>    #include <sched.h> int clone(int (*fn)(void *), void
  Nathan> *child_stack, int flags, void *arg); _syscall2(int, clone,
  Nathan> int, flags, void *, child_stack);

  Nathan> What are the parameters parent_tid, tls, and child_tid
  Nathan> supposed to be?

Hint 1: search google for "NPTL".
Hint 2: it's nothing ia64-specific.
Hint 3: the arguments are ignored unless you specify certain CLONE* flags,
        so the interface remains backwards-compatible.

Hope this helps.

	--david
