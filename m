From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 13 Sep 2001 19:52:09 +0000
Subject: Re: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805178@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 10 Sep 2001 21:30:02 -0700, Ulrich Drepper <drepper@redhat.com> said:

  Uli> David Mosberger <davidm@hpl.hp.com> writes:
  >> As far as I can see, neither LSB nor FHS address the issue of
  >> where to place emulation files, so I'll propose a prefix of
  >> "/emul/ia32-linux/" as a starter.  Any objections?

  Uli> Not that I care, but this is clearly a place for a new /proc
  Uli> entry which can be changed by the sysadmin.

I'd have thought that this should be treated like "/": an unchanging
prefix.  Mount, symlinks, and chroot are your friend.  Making it
variable makes installation harder, as others have pointed out.  But
it's not like I care a whole lot (as long as ia64 kernel performance
isn't impacted noticably).

	--david

