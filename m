From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 18 Apr 2000 23:12:39 +0000
Subject: Re: [Linux-ia64] Kernel long branch support
Message-Id: <marc-linux-ia64-105590678205019@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205018@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205018@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 18 Apr 2000 18:47:38 -0400, roneng@ca.ibm.com said:

  Ronen> Hi, I am getting an illegal instruction fault from the kernel
  Ronen> after using the latest linker which supports long branches
  Ronen> (i.e. branches greater then 16M) to compile large shared
  Ronen> libraries.  I was wondering if anyone knows if the latest
  Ronen> kernels 2.3.51/or 2.3.50 support long branches, or if anyone
  Ronen> is working on long branch support for the kernel.

The kernel support for "branch long" emulation doesn't exist yet.
Patch welcome. ;-)

	--david


