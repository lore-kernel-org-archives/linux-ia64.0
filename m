From: Nathan Straz <nstraz@sgi.com>
Date: Thu, 10 Jul 2003 16:18:38 +0000
Subject: Re: clone testcases in LTP
Message-Id: <marc-linux-ia64-105785417917339@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105778639326638@msgid-missing>
In-Reply-To: <marc-linux-ia64-105778639326638@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 09, 2003 at 03:17:42PM -0700, David Mosberger wrote:
> The only difference between clone() and clone2() is the explicit
> stack-size argument.  clone2() is discussed in detail in my book, but
> if you're already familiar with clone(), it's easy to understand
> what's going on.  Here is the pseudo prototype (from glibc):
> 
> /* int  __clone2(int (*fn) (void *arg), void *child_stack_base,	*/
> /*	         size_t child_stack_size, int flags, void *arg,		*/
> /*	         pid_t *parent_tid, void *tls, pid_t *child_tid)	*/

Hmm, that prototype seems to have a lot more args than the clone man
page states:

   #include <sched.h>
   int clone(int (*fn)(void *), void *child_stack, int flags, void *arg);
   _syscall2(int, clone, int, flags, void *, child_stack);

What are the parameters parent_tid, tls, and child_tid supposed to be?
-- 
Nate Straz                                              nstraz@sgi.com
sgi, inc                                           http://www.sgi.com/
Linux Test Project                                  http://ltp.sf.net/
