From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 21 Jan 2002 22:41:03 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805910@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 21 Jan 2002, David Mosberger wrote:

>   Ingo> Besides causing the current bug, it was superfluous in the old
>   Ingo> scheduler as well, so i'm only wondering aloud - perhaps there
>   Ingo> were more subtle reasons as well?
>
> No, it wasn't superfluous.  It had to re-establish the original state
> after disabling interrupts to switch the TLB pinning.

since it went in pair with an irq-disable, it was indeed necessery.

i think i understand it now.

the end result: in the new scheduler it's guaranteed that switch_to() is
called with local interrupts disabled, and it's not allowed to reenable
them during switch_to().

	Ingo


