From: Jay Lan <jlan@sgi.com>
Date: Mon, 20 Nov 2006 23:33:25 +0000
Subject: Re: [PATCH]send slave cpus to SAL slave loop on crash (IA64)
Message-Id: <45623B45.7060302@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4546623D.5000105@engr.sgi.com>
In-Reply-To: <4546623D.5000105@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou, Nanhai wrote:
>> We do not rely on machine crash on CPU 0 any more. If the
>> crashing CPU is not cpu 0 and the cpu 0 not being returned to
>> the slave loop, this case is handled by our PROM now.
>>
>> However, if somebody tries to boot up a production kernel using '-le'
>> option _after_ the kexec'ed kernel is up running, the third kernel
>> would not boot unless we boot up the second kernel with cpu 0. I
>> posted a question on "if running 'kexec -le' on a kexec'ed kdump
>> kernel is legal" earlier and Vivek responded saying the scenario
>> is not guranteed to work. So, i think we are fine here.
>>     
>
>   Ok, so with this patch and the PROM fix, on a SN system,
>   1. Kdump -> 2nd kernel works.
>   2. Kdump -> 2nd kernel -> Kexec to third kernel will not work.
>   3. Kexec -> 2nd Kernel -> Kexec -> 3rd kernel works?
>   4. Kexec -> 2nd Kernel -> Kdump -> 3rd kernel works?
>
>   I think if scenario 1, 3 and 4 works it will be ok. Scenario 2 is not so useful I guess.
>   

With the patch Nanhai sent to me to fix '-l' option on SN system,
now scenario 1, 3 and 4 all works. Of course, you need to include
'crashkernel' parameter in "append" option when you do 'kexec -l'
in order for scenario #4 to work. You do not need crashkernel
parameter for #3 though.

Thanks,
- jay


