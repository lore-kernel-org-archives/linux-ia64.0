From: Ulrich Drepper <drepper@redhat.com>
Date: Sun, 27 May 2001 06:45:12 +0000
Subject: [Linux-ia64] Re: libc patch: update of memcpy et al
Message-Id: <marc-linux-ia64-105590693005673@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

> The patch below bring the performance of memcpy(), memmove(), bcopy(),
> and bzero() up to more reasonable levels.  I haven't run this through
> "make check", but I believe the changes to be OK.

The changes seem fine, I ran make check.  Thanks.  But you were really
naughty and edited the patch.  Tss, tss, tss, don't do that, it's so
easy to do it wrong just as in this case.

Also, there is no need to introduce __memmove.  __-protected functions
are only necessary to prevent namespace problems.  Since memmove is
defined in the most basic standards there is no problem at all.

Thanks,

-- 
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

