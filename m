From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 09 Jan 2001 21:44:34 +0000
Subject: Re: [Linux-ia64] IA-64 Linux TODO list
Message-Id: <marc-linux-ia64-105590678205901@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205896@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 9 Jan 2001 14:25:14 -0700, Kevin Buettner <kev@primenet.com> said:

  >> > - gdb > - NaT bits don't seem to work properly?  > - coredump
  >> support still broken?

  Kevin> I have a couple of other items to add to this list of things
  Kevin> which isn't working in gdb.

  Kevin> 1) Calling inferior functions no longer works.  (At least it
  Kevin> didn't in the recent Red Hat release.  I'm rebuilding gdb now
  Kevin> with the TurboLinux release to check it there.) I've done
  Kevin> some investigation of this problem and it looks to me like
  Kevin> the RSE backing store is changing under us (gdb that is) when
  Kevin> bsp is changed.

  Kevin> 2) Hardware watchpoints no longer work.  Again, the value
  Kevin> returned by the kernel looks suspect.  There appear to be a
  Kevin> couple of bits that were reset...

  Kevin> In general, the state of gdb isn't as good right now as it
  Kevin> used to be.  There was a time when I was seeing only between
  Kevin> 20-30 test suite failures.  The number is now over 700.

It wouldn't surprise me if some of the issues are due to kernel bugs
and I'll certainly be happy to work with you on getting those issues
resolved.  Getting gdb to be reliable (again) is definitely high on my
priority list.

	--david

