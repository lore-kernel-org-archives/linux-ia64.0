From: "R. Lake" <rich@lakes.plus.com>
Date: Fri, 17 Oct 2003 08:13:31 +0000
Subject: Re: load-store emulation with SIGSEGV
Message-Id: <marc-linux-ia64-106637851925948@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106634457403703@msgid-missing>
In-Reply-To: <marc-linux-ia64-106634457403703@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Rich> I'm investigating a means of emulating causes of SEGV where
>   Rich> they can be isolated from genuine failure. For example, a rule
>   Rich> stating a load from address 0x100 "loads" the value 42 into
>   Rich> the target register.
>
> I'm not entirely sure I understand what you're trying to do and
> whether you're doing it in the kernel or user (signal-handler).  If
> the latter, adjusting the sc_ip should be sufficient (the slot number
> is encoded in bits 0 and 1 of sc_ip).
>
> --david

The current implementation is a user mode signal handler, so as you say
adjusting sc_ip ought to be okay. I'll run some more thorough asm tests to
check my usage of rse_skip_regs and make certain subsequent instructions are
executed from the faulting bundle. Thanks for your help.

Regards,
Richard.


