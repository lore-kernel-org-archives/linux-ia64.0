From: Francis Galiegue <fg@mandrakesoft.com>
Date: Tue, 17 Oct 2000 17:17:30 +0000
Subject: Re: [Linux-ia64] Instruction Execution
Message-Id: <marc-linux-ia64-105590678205578@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205577@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205577@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 17 Oct 2000, Mattox, Dave wrote:

> 
> I ran a loop 666,000,000 times and it appears that each bundle is taking 3
> seconds to execute. So this means 3 cycles per bundle,
> or 1 cycle per instruction. Is the Lion SDV Machine executing instructions
> serially? If it is, is it Linux setting this, or are the beta chips disabled
> in some manner?
> 

ia64 does not do instruction reordering, at least this is what I've heard, and
nothing which I have read until now seems to deny this. All insn ordering for
faster execution should therefore be done by the compiler.

No URL to give you, sorry...

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


