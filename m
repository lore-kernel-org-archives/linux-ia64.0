From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 03 Apr 2022 05:13:20 +0000
Subject: Re: [PATCH 1/3 v2] Docs: admin/kernel-parameters: edit a few boot options
Message-Id: <53133d81-e52c-8887-c879-615b585e3351@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220401030927.12023-1-rdunlap@infradead.org>
 <20220401030927.12023-2-rdunlap@infradead.org>
 <20220401120305.00076d14@gandalf.local.home>
In-Reply-To: <20220401120305.00076d14@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, linux-s390@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-ia64@vger.kernel.org, "Rafael J. Wysocki" <rafael@kernel.org>, Pavel Machek <pavel@ucw.cz>, Len Brown <lenb@kernel.org>, linux-pm@vger.kernel.org, linux-acpi@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org



On 4/1/22 09:03, Steven Rostedt wrote:
> On Thu, 31 Mar 2022 20:09:25 -0700
> Randy Dunlap <rdunlap@infradead.org> wrote:
> 
>> @@ -5908,6 +5910,8 @@
>>  	trace_buf_size=nn[KMG]
>>  			[FTRACE] will set tracing buffer size on each cpu.
>>  
>> +	trace_clock=	[FTRACE] See Documentation/trace/ftrace.rst
> 
> 	trace_clock=	[FTRACE] Set the clock used for tracing events
> 			at boot up.
> 			local - Use the per CPU time stamp counter
> 				(converted into nanoseconds). Fast, but
> 				depending on the architecture, may not be
> 				in sync between CPUs.
> 			global - Event time stamps are synchronize across
> 				CPUs. May be slower than the local clock,
> 				but better for some race conditions.
> 			counter - Simple counting of events (1, 2, ..)
> 				note, some counts may be skipped due to the
> 				infrastructure grabbing the clock more than
> 				once per event.
> 			uptime - Use jiffies as the time stamp.
> 			perf - Use the same clock that perf uses.
> 			mono - Use ktime_get_mono_fast_ns() for time stamps.
> 			mono_raw - Use ktime_get_raw_fast_ns() for time
> 				stamps.
> 			boot - Use ktime_get_boot_fast_ns() for time stamps.
> 			Architectures may add more clocks. See
> 			Documentation/trace/ftrace.rst for more details.
> 

Will do. Thanks.

> 
> 
>> +
>>  	trace_event=[event-list]
>>  			[FTRACE] Set and start specified trace events in order
>>  			to facilitate early boot debugging. The event-list is a

-- 
~Randy
