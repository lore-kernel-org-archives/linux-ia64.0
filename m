From: Pavel Machek <pavel@ucw.cz>
Date: Tue, 20 Apr 2004 19:40:17 +0000
Subject: Re: Dynamic System Calls & System Call Hijacking
Message-Id: <20040420194016.GF1413@openzaurus.ucw.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <4084E85E.4722BFC6@nospam.org>
In-Reply-To: <4084E85E.4722BFC6@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan.Menyhart@bull.net
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi!

> - Can't recompile the kernel, otherwise you gonna lose RedHat guarantee ?
>   Or some ISVs like whose name starts with an "O" and terminates with "racle"
>   ain't gonna support it ?
 
>   + No problem, I'll load your syscall in a module.

Well, by forcing syscall in, you loose your guarantee, too.
cat /dev/urandom > /dev/kmem

"RedHat, help, my machine crashed."


> Your remarks will be appreciated.

I hope it at least taints the kernel.

And you did test on smp kernel, trying to race syscall calling against
your module load/unload, right?

-- 
64 bytes from 195.113.31.123: icmp_seq( ttlQ timeD8769.1 ms         

