From: Ray Bryant <raybry@sgi.com>
Date: Mon, 22 Nov 2004 18:56:34 +0000
Subject: Re: [Lse-tech] scalability of signal delivery for Posix Threads
Message-Id: <41A23662.40305@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41A20AF3.9030408@sgi.com> <20041122162214.GE21861@wotan.suse.de> <jept25yggg.fsf@sykes.suse.de> <20041122165425.GG21861@wotan.suse.de>
In-Reply-To: <20041122165425.GG21861@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Andreas Schwab <schwab@suse.de>, Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, lse-tech <lse-tech@lists.sourceforge.net>, holt@sgi.com, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

Andi Kleen wrote:
> On Mon, Nov 22, 2004 at 05:51:59PM +0100, Andreas Schwab wrote:
> 
>>Andi Kleen <ak@suse.de> writes:
>>
>>
>>>At least in traditional signal semantics you have to call sigaction
>>>or signal in each signal handler to reset the signal. So that 
>>>assumption is not necessarily true.
>>
>>If you use sigaction then you get POSIX semantics, which don't have this
>>problem.
> 
> 
> It's just a common case where Ray's assumption is not true.
> 
> -Andi
> 

True enough.  And in that case the design that I was describing wouldn't
make sigaction() that much more expensive since if you are not in the POSIX
thread environment (more precisely, the thread was not created with
CLONE_SIGHAND) each thread has its own sighand structure and the "global" 
locking mechanisum I had proposed would only require the taking of one 
additional lock.

However, special casing ITIMER_PROF is also a reasonable avenue of approach.
The performance monitor code can also deliver signals to user space when
a sampling buffer overflows, and this can have the same kind of scaling
problem as ITIMER_PROF.  I'll have to do a little research to figure out
how exactly that works, but that signal (SIGIO?) would also be a candidate
for special casing on our platform.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
