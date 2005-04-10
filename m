From: Keith Owens <kaos@sgi.com>
Date: Sun, 10 Apr 2005 23:58:24 +0000
Subject: Re: [PATCH] salinfo_decode silent exit in older 2.4s
Message-Id: <6557.1113177504@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1112995423.7189.133.camel@krebs.dannf>
In-Reply-To: <1112995423.7189.133.camel@krebs.dannf>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 08 Apr 2005 15:23:43 -0600, 
dann frazier <dannf@hp.com> wrote:
>I was playing with salinfo_decode on an older kernel (2.4.21 era) and it
>would normally die silently right after exec.
>
>This no longer happens because of a semantic difference that occurred in
>later 2.4 kernels.  Older 2.4s would return -EINTR when they wanted
>userspace to try again, while current 2.4s use -ERESTARTSYS.  (The
>surrounding code is also somewhat different, but it looks like the idea
>is the same).

ERESTARTSYS should never be seen by user space code.  The kernel should
either restart the current syscall or convert the code to EINTR before
returning to user space.  If you are seeing ERESTARTSYS in user space
then it is a kernel bug.

