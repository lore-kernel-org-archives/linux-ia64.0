From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 16 Apr 2003 23:05:23 +0000
Subject: Re: [Linux-ia64] Fix error checking in sys32_ptrace
Message-Id: <marc-linux-ia64-105590723705519@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705335@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705335@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 27 March 2003 8:02 am, Andreas Schwab wrote:
> This fixes sys32_ptrace to use ptrace_check_attach, so that it
> automatically inherits all future enhancements there.

I applied this in 2.4.

