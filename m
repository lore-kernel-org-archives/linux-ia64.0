From: Chandra Kapate <cs_kapate@yahoo.com>
Date: Tue, 08 Apr 2003 13:28:57 +0000
Subject: Re: [Linux-ia64] A clarification about sys32_execve/ia32_execve
Message-Id: <marc-linux-ia64-105590723705437@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705421@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705421@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for clarifying.
Chandra
--- David Mosberger <davidm@napali.hpl.hp.com> wrote:
> Hi Chandra,
> 
> >>>>> On Fri, 4 Apr 2003 09:50:16 -0800 (PST),
> Chandra Kapate <cs_kapate@yahoo.com> said:
> 
>   Chandra> Hi,
>   Chandra> I was looking at how execve syscalls work
> wrt to 32/64
>   Chandra> syscalls. I have a basic question. I
> appreciate if
>   Chandra> some once can clarify. I apologize if I
> am overlooking
>   Chandra> some thing very obvious.
> 
>   Chandra> The ia32_execve (in ia32_entry.S) sets up
> out0, out1,
>   Chandra> out2 and out3 before invoking
> sys32_execve. The out3
>   Chandra> is setup for regs. But, in sys32_execve,
> the regs
>   Chandra> is set locally using 9th parameters. I
> can see how
>   Chandra> the regs is set using 9th parameter. I
> don't 
>   Chandra> understand  why is set again in
> sys32_execve
>   Chandra> when it is already set in out3 in
> ia32_execve and 
>   Chandra> could have used as 4th parameter? Does
> args mis-match 
>   Chandra> between ia32_execve and sys32_execve
> matter? 
>   Chandra> OTH, sys_execve does use the regs set in
> ia64_execve.
>   Chandra> Sorry, if i am overlooking something.
> 
> Looks like you found an inconsistency.  The code
> should work as it
> stands, but it certainly looks confusing.  It looks
> to me like one end
> of the interface was updated at one point but not
> the other.
> 
> The reason sys32_execve() works is because the 9th
> (scalar) argument
> is the first argument that gets passed on the stack.
>  Taking its
> address will give "sp+16", which is exactly what
> out3 is set to.
> 
> Thanks for pointing out this inconsistency (I'll see
> about fixing it).
> 
> 	--david


__________________________________________________
Do you Yahoo!?
Yahoo! Tax Center - File online, calculators, forms, and more
http://tax.yahoo.com

