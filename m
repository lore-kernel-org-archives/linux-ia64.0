From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 27 Sep 2001 08:31:24 +0000
Subject: [Linux-ia64] Re: kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805267@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Sep 2001 17:59:11 -0400, Bill Nottingham <notting@redhat.com> said:

  Bill> David Mosberger (davidm@hpl.hp.com) said:
  >> with these fixes in place, I'm able to successfully run the ia32
  >> versions of realplay, OpenOffice, mozilla, netscape, acrobat,
  >> strace, Intel compilers, etc.  But as usual, your mileage may
  >> vary.

  Bill> Did you try wine? :)

I hadn't.

  Bill> Seriously, I tried this previously, and it didn't really work
  Bill> at all.  At the time, I wasn't even sure if it could be *made*
  Bill> to work, and I haven't looked since.

I wasn't sure either.  I looked at the docs a bit and there doesn't
seem to be anything that would stop it from working in principle.
16-bit apps might be harder, as those require vm86() which I know
nothing about (I'm sure it could be implemented by someone more
knowledge of x86).

Encouraged by this, I tried the wine RPM from Red Hat. After fixing
the ia32 sendmsg()/recvmsg() implementations, I am now able to run
"wordpad.exe" and "mspaint.exe".  I had never seen wine in a working
state, so I was quite amazed to see a windows-looking application pop
up!  As far as I can tell, these two apps work perfectly fine.

However, I didn't get much else to work (e.g., acrobat and the HP
printing software both died after the splash screen...).  Even with
"wordpad.exe" I get some worrisome warning messages:

 err:win32:fixup_imports No implementation for shlwapi.dll.0(StrRetToBufA) imported from shell32.dll, setting to 0xdeadbeef
 err:win32:fixup_imports No implementation for shlwapi.dll.0(StrRetToBufW) imported from shell32.dll, setting to 0xdeadbeef
 FIXME:pthread_rwlock_rdlock
 FIXME:pthread_rwlock_unlock

I think the first two errors are real problems.  Not sure about the
pthread-related messages.  I suppose if someone is serious about this,
all of these could be fixed.

Oh, to get this to work, I had to switch to 4KB page size.

	--david

