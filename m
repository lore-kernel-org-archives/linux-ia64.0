From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Jan 2005 19:54:54 +0000
Subject: Re: glibc-2.3.2 NPTL caveat
Message-Id: <16885.21134.529399.543212@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16879.19106.549352.469688@napali.hpl.hp.com>
In-Reply-To: <16879.19106.549352.469688@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Jan 2005 11:34:26 +0000, Tim Cutts <tjrc@sanger.ac.uk> said:

  Tim> That explains a lot of problems we had with MySQL crashing
  Tim> almost instantly on startup on IA64 machines too.

Hmmh, was this problem reported somewhere?

  Tim> So what needs to be done?

If you run on Debian, the easiest workaround for now is probably to
invoke the program via /lib/tls/ld-linux-ia64.so.2.

Of course, you could also force the use of the LinuxThread-based libc
by setting environment variable LD_ASSUME_KERNEL to 2.4.18, but if you
want NPTL, that's not a useable solution.

	--david
