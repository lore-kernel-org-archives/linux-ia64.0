From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Nov 2003 21:21:07 +0000
Subject: Re: [PATCH] remove unimplemented syscalls noise
Message-Id: <marc-linux-ia64-106927695808041@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106926030617023@msgid-missing>
In-Reply-To: <marc-linux-ia64-106926030617023@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Nov 2003 20:35:51 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> On Wed, Nov 19, 2003 at 12:33:17PM -0800, David Mosberger
  Matthew> wrote: Every time we emit something to the system log, it's
  Matthew> a potential support call.  Our friends in other parts of HP
  Matthew> are already unhappy with how much output Linux produces
  Matthew> even when everything's OK.  It's also a sysadmin hassle as
  Matthew> logfiles fill up more quickly when this kind of junk goes
  Matthew> by.

  >>  Can I say dmesg -n4??

  Matthew> No, you can't.  Users check their logfiles.

syslog.conf?

I don't see how you can argue that debug/informational messages
_shouldn't_ be displayed/logged for ordinary users under normal
circumstances yet argue _for_ configuring syslog.conf to log precisely
such messages.

I'm quite certain there are countless other ways for user-space to
trigger lots of KERN_INFO/KERN_DEBUG messages.  See kernel/sysctl.c or
security/security.c, for example.

Having said that, I now realize that there is a problem:
ia64_ni_syscall() is/was intended for syscalls that were supposed to
be implemented but were missing for some reason.  Everything else
should be handled by sys_ni_syscall.  There are no such syscalls
anymore, so I think what we should do is change entry.S from using
ia64_ni_syscall to sys_ni_syscall (and if there are no callers of
ia64_ni_syscall left, delete it).  Want to send a patch?

	--david
