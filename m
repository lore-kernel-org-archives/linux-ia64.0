From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Mar 2003 20:49:52 +0000
Subject: Re: [Linux-ia64] Fix error checking in sys32_ptrace
Message-Id: <marc-linux-ia64-105590723705340@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705335@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705335@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 Mar 2003 16:02:48 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> This fixes sys32_ptrace to use ptrace_check_attach, so that it
  Andreas> automatically inherits all future enhancements there.

The patch didn't apply in 2.5, but I merged it manually.

Thanks,

	--david

