From: Don Dugger <n0ano@valinux.com>
Date: Wed, 25 Oct 2000 14:28:06 +0000
Subject: Re: [Linux-ia64] static registers during a context switch
Message-Id: <marc-linux-ia64-105590678205624@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205620@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205620@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If you are thinking of a context switch in the sense of switching
from one process to another then ALL registers, static and stacked,
are saved and restored.  If you are talking about making a subroutine
call then the uses of the static registers are covered by software
convention and registers R4-R7 are preserved across a function call.

Conceptually the static registers are similar to the X86 registers
EAX, EBX and so on.  These registers are also saved and restored
across context switches and have software conventions that control
which ones are saved across subroutine calls.

On Tue, Oct 24, 2000 at 09:47:41PM -0500, riedel wrote:
> hi everybody,
> does anybody know what happens to static registers (gr0-gr31) in case of a context switch.
> in the manual, it says static registers are visible to all procedures(i guess it shouldn't otherwise on a context switch another process would have the same static registers) On the other hand, stacked registers are local to procedures and saved and restored by RSE which makes sense to me.

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

