From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Jun 2004 06:04:34 +0000
Subject: Re: GLIBC IA64 HP_TIMING fixes for SMP systems with unsynchronized ITC
Message-Id: <16576.4338.739471.384600@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406031313420.32412@server.home>
In-Reply-To: <Pine.LNX.4.58.0406031313420.32412@server.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 3 Jun 2004 13:28:35 -0700 (PDT), Christoph Lameter <christoph@lameter.com> said:

  Christoph> The following patch checks for drifty ITC clocks based on
  Christoph> that file. If ITC is drifty then it generates timestamps
  Christoph> based on the gettimeofday system call.

Does anyone else find it annoying that gettimeofday() only provides
micro-second resolution?  We can do syscalls significantly faster than
that (especially with a light-weight syscall handler).  Time for a
kernel extension?

	--daivd
