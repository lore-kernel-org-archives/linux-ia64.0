From: Ulrich Drepper <drepper@redhat.com>
Date: Thu, 27 Feb 2003 09:33:38 +0000
Subject: [Linux-ia64] Re: unwind info fix for ia64
Message-Id: <marc-linux-ia64-105590709805938@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> Here is a small bug-fix for libc's __syscall_error to get the unwind
> info correct.  Did "make check" afterwards and ran a test program to
> verify that unwinding works correctly now for this function.

I've applied the patch.  Thanks,

-- 
--------------.                        ,-.            444 Castro Street
Ulrich Drepper \    ,-----------------'   \ Mountain View, CA 94041 USA
Red Hat         `--' drepper at redhat.com `---------------------------


