From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 16 Apr 2003 22:56:55 +0000
Subject: Re: [Linux-ia64] Fix request_module from ia32 process
Message-Id: <marc-linux-ia64-105590723705520@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705333@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705333@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 27 March 2003 7:07 am, Andreas Schwab wrote:
> When an ia32 process triggers request_module the kernel cannot execute
> modprobe because the kernel thread still has the ia32 address limits in
> force.  I think a kernel thread should always have the ia64 address
> limits, similar to what sys32_execve is doing.

I applied this in 2.4.

