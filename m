From: Richard Henderson <rth@redhat.com>
Date: Wed, 05 Dec 2001 01:14:26 +0000
Subject: Re: [Linux-ia64] Bug in signal handling
Message-Id: <marc-linux-ia64-105590698805613@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805573@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805573@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 03, 2001 at 06:19:52PM -0800, David Mosberger wrote:
> Richard, I'm cc'ing you because it appears to me that Alpha Linux may
> have the same problem.

I don't think it does:

        bne     $5,signal_return
restore_all:
        RESTORE_ALL
        call_pal PAL_rti
[...]
signal_return:
        mov     $30,$17
        br      $1,do_switch_stack
        mov     $30,$18
        mov     $31,$16
        jsr     $26,do_signal
        bsr     $1,undo_switch_stack
        br      restore_all

That is, after do_signal we restore registers and return.

Unless you meant something else?


r~

