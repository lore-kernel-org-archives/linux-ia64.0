From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Mon, 21 Apr 2003 17:21:05 +0000
Subject: Re: [Linux-ia64] print backtrace from OS INIT handler
Message-Id: <marc-linux-ia64-105590723705578@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705506@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705506@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 15 April 2003 2:24 pm, David Mosberger wrote:
> The patch below is relative to 2.5.67 and adds support to print a
> backtrace from the OS INIT handler.  The complete INIT output looks
> now something like shown below.  The example is for the case when INIT
> is received while a CPU is idle in PAL_LIGHT_HALT.  Caveat: at the
> moment, the INIT handler doing this dumping is called only on the
> bootstrap CPU.  Hopefully, this can be extended to cover the other
> CPUs without too much trouble (hint hint... ;-).

I applied this (without extension to other CPUs ;-) for 2.4, although
we don't have print_symbol() in 2.4, so we don't get the nice IP decoding.
I also picked up the earlier min-state dump changes.

Bjorn


