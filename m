From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 03 Dec 2001 03:15:16 +0000
Subject: Re: [Linux-ia64] Bug in signal handling
Message-Id: <marc-linux-ia64-105590698805575@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805573@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805573@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 02 Dec 2001 23:05:29 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> Then send both SIGUSR1 and SIGUSR2 to the process from
  Andreas> another terminal.  If they arrive close enough then the
  Andreas> first signal handler will be interupted at GATE_ADDR by the
  Andreas> second handler.  But ia64_do_signal is again called with
  Andreas> in_syscall = 1, and it will call ia64_decrement_ip before
  Andreas> setting up the signal handler frame.  Thus when the second
  Andreas> signal returns then rt_sigreturn it will return to
  Andreas> GATE_ADDR - 16 and crashes.

I think I know what the problem is.  If I'm right, then, oddly enough,
I discovered the same bug just yesterday (while proof-reading the
book, nevertheless... ;-).

Anyhow, I'll look into it on Monday.

Thanks,

	--david

