From: Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net>
Date: Wed, 31 Mar 2004 06:37:01 +0000
Subject: Re: Abnormal behaviour towards "INIT" interrupt management
Message-Id: <406A670D.8040101@Ext.Bull.Net>
List-Id: <linux-ia64.vger.kernel.org>
References: <40691B80.9070309@Ext.Bull.Net>
In-Reply-To: <40691B80.9070309@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>>Then I push on the "dump" button that generates an INIT interruption to 
>>all the processors. This signal is then caught by PAL, and SAL which 
>>calls (with a reason [register GR11] equal to 2) 
>>"ia64_monarch_init_handler" on the monarch processor and 
>>"ia64_slave_init_handler" on the slave ones (to this point, I hope to be 
>>right, isn't it ?).
> 
> 
> Yes.  If I understand correctly, you observe that one processor
> calls ia64_monarch_init_handler(), and all the others call
> ia64_slave_init_handler().  So far, that is correct behavior.

Hum, in fact, that's the behaviour I was expecting to observe... reading 
the kernel code.

>>What I've noticed using traces (and further an ITP tool) is that for 
>>each processor the "ia64_monarch_init_handler" is ever called. :-(
> 
> 
> Are you saying that more than one processor calls
> ia64_monarch_init_handler()?  If so, I think something
> is broken.  But I haven't seen that behavior.  Here is
> ia64_slave_init_handler():
> 
> 	GLOBAL_ENTRY(ia64_slave_init_handler)
> 	1:      br.sptk 1b
> 	END(ia64_slave_init_handler)
> 

Right, I was just surprised to see 4 times the trace "Entered OS INIT 
handler" appearing on my console screen. Then, I ran a JTAG debugger
to set breakpoints in the kernel code and noticed that all CPUs called
the same function, e.g. "ia64_monarch_init_handler" (without using
any Rendez-Vous mechanism ?!).

> So I'd be surprised to see the slave processors do anything
> interesting.
> 
> I do know that we are missing some useful behavior in this area --
> namely, we don't extract the min-state area for the slave processors,
> so we don't get backtraces for the currently-running tasks on them.

On that precise point, I thougt that PAL was recording register states
in a processor dedicated area called "min-state area" for each processor
receiving INIT signal (and in the present case all the processors catch 
it). Can you confirm this ?

In fact, I want to be able pushing the "dump" button to get the 
information for all the running processors (and not just one) and then 
determine for example which one is "deadlocking".

