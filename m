From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 29 Dec 2003 19:57:32 +0000
Subject: Re: GL-related crash w/ X 4.3 & kernel 2.6
Message-Id: <marc-linux-ia64-107272856028654@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107272704926812@msgid-missing>
In-Reply-To: <marc-linux-ia64-107272704926812@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 29 Dec 2003 19:41:44 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> The machine is a zx2000 workstation with a Radeon 7000/VE
  Matthew> card.  Kernel is 2.6.0 plus some additional changes (mostly
  Matthew> jgarzik's latest netdrivers patch) [but it's happened with
  Matthew> other 2.6 kernels].  The X server is Debian's 4.3.0-0pre1v5
  Matthew> [but it's happened with other 4.3.0 releases].

Do you have DRI enabled?  I pretty much had given up on Radeon hw
accelleration, because if failed for me in the same manner on both x86
and ia64.  Perhaps things have improved in the meantime?

Hardware-accellerated OpenGL did work fine for me with Nvidia until
the recent glibc upgrade forced me to turn it off for now.  I hadn't
tried FlightGear though.

>>>>> On Mon, 29 Dec 2003 19:41:44 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> Second, since neither strace nor gdb is willing to
  Matthew> cooperate in helping to track this down, can anyone more
  Matthew> knowledgable than I about the ways of GL suggest how to
  Matthew> start debugging this?

You mean you can't use gdb to attach to the CPU-hogging processes?  My
guess would be that the server and the app get stuck trying to acquire
a lock, which is incidentally an area that the Radeon DRI driver had
problems with in the past.

	--david
