From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 31 May 2001 05:33:03 +0000
Subject: Re: [Linux-ia64] Bug report: 4-threaded program gets seg. fault on malloc, on linu
Message-Id: <marc-linux-ia64-105590693005677@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005668@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005668@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 25 May 2001 16:17:37 -0700, "Robboy, David G" <david.g.robboy@intel.com> said:

  David.R> I have reported this on bugzilla also, Bug #42354.  I don't
  David.R> know whether it is a kernel bug, libc, or libpthread.  The
  David.R> attached program spawns 3 new threads, and each of the 4
  David.R> threads does a malloc.  Run it on a 4P Lion.  On Linux
  David.R> kernel R2.4.3 (Red Hat release 7.0.98), it aborts with a
  David.R> segmentation fault.  The same binary executable runs
  David.R> correctly on a R2.4.1 kernel.

You didn't say how you compiled the program.  Let's assume you used
"gcc -O2 -pthread": for what it's worth, this works fine here, both on
Wolverine and Guinness.  In both cases with kernel 2.4.4 and on
Wolverine I'm using glibc-2.2.2-10.

	--david

