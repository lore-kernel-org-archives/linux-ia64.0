From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 21 Jan 2002 22:30:32 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805908@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 21 Jan 2002, David Mosberger wrote:

>   Ingo> oh, i see. Why were irqs enabled explicitly? The old scheduler
>   Ingo> called switch_to() with irqs enabled, all the time.
>
> Eh, that's not true. [...]

my 'Why were irqs enabled explicitly' question referred to the ia64
switch_to() code, which, if i understand this thread correctly, enables
interrupts internally.

Besides causing the current bug, it was superfluous in the old scheduler
as well, so i'm only wondering aloud - perhaps there were more subtle
reasons as well?

	Ingo


