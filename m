From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Mar 2003 22:07:42 +0000
Subject: Re: [Linux-ia64] Pre-emption patch for IA-64
Message-Id: <marc-linux-ia64-105590709806119@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806101@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806101@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 15 Mar 2003 08:57:55 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> On a dual McKinley prototype machine I was able to get
  Peter> lockups with preempt under heavy I/O and cpu load (e.g., make
  Peter> -j4 in glibc).  I'm waiting for production model McKinleys
  Peter> SMP to retry, as I couldn't reproduce the problem on
  Peter> production-model Itanium 1, and there were no symptoms that I
  Peter> could debug.

Do you know what on the zx1-based machines you can trigger INIT via
the BMC?  That's quite handy when the kernel locks up (you can dump
the collected state at the next boot).

	--david

