From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Feb 2004 21:41:02 +0000
Subject: Re: [RFC][PATCH] linux-2.6.3-rc2_ia64-cyclone_A0
Message-Id: <16434.35438.828109.657297@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1076556140.795.119.camel@cog.beaverton.ibm.com>
In-Reply-To: <1076556140.795.119.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 16 Feb 2004 18:46:58 -0800, john stultz <johnstul@us.ibm.com> said:

  John> So, as it seems the hardware currently doesn't set the
  John> ITCdrift flag, should I then set it in my init code?

As a temporary workaround, that seems like a reasonable solution.

  John> Or is there some other way of disabling fsys support, possibly
  John> on a per-syscall basis?

You can't disable fsys-support itself, but you can turn off the use of
light-weight handlers by booting the kernel with option "nolwsys".  I
wouldn't recommend that though because it's a sledgehammer and will
disable all other lightweight syscalls as well (getpid, getppid,
set_tid_address, and sigprocmask, for now).

	--david
