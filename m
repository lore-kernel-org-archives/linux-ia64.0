From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 13 Mar 2003 21:57:16 +0000
Subject: [Linux-ia64] Re: POSIX timers interface for IA64
Message-Id: <marc-linux-ia64-105590709806084@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 07 Mar 2003 14:40:04 +0100, Eric Piel <Eric.Piel@Bull.Net> said:

  Eric> Hello, Here is a patch to have the POSIX timer interface
  Eric> completly integrated in ia64 (2.5.64). The programs in
  Eric> userland can now access the siginfo structure. With that patch
  Eric> the test programs of the high resolution timers pass without
  Eric> error but one which seems to also be triggered on ix86:
  Eric> nanosleeps too short.

  Eric> I did the same modifications to the ia32 support but I wasn't
  Eric> able to test them.

I applied this patch in my (ia64) tree.

Thanks!

	--david

