From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Mar 2003 20:43:26 +0000
Subject: Re: [Linux-ia64] Fix request_module from ia32 process
Message-Id: <marc-linux-ia64-105590723705339@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705333@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705333@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 Mar 2003 15:07:32 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> When an ia32 process triggers request_module the kernel
  Andreas> cannot execute modprobe because the kernel thread still has
  Andreas> the ia32 address limits in force.  I think a kernel thread
  Andreas> should always have the ia64 address limits, similar to what
  Andreas> sys32_execve is doing.

Applied in 2.5, thanks.

	--david

