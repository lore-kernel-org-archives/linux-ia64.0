From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Nov 2003 21:31:55 +0000
Subject: Re: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106927776209244@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Nov 2003 13:21:07 -0800, David Mosberger <davidm@linux.hpl.hp.com> said:

  >> Having said that, I now realize that there is a problem:
  >> ia64_ni_syscall() is/was intended for syscalls that were supposed
  >> to be implemented but were missing for some reason.  Everything
  >> else should be handled by sys_ni_syscall.  There are no such
  >> syscalls anymore, so I think what we should do is change entry.S
  >> from using ia64_ni_syscall to sys_ni_syscall (and if there are no
  >> callers of ia64_ni_syscall left, delete it).  Want to send a
  >> patch?

Actually, in the interest of keeping the patch small, it's better to
remove the printk message in ia64_ni_syscall() for 2.6.0 and then we
can do the proper cleanup for 2.6.1.

	--david
