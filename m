From: Eric Sandeen <sandeen@sandeen.net>
Date: Thu, 16 Jul 2009 22:22:39 +0000
Subject: Re: [PATCH, RFC] xfs: event tracing support
Message-Id: <4A5FA82F.6050903@sandeen.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090616214844.GA12310@infradead.org>	<4E752C93-A674-4725-AF23-C227C0A1E659@sgi.com>
	<20090622205904.GA1855@infradead.org>
In-Reply-To: <20090622205904.GA1855@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-ia64@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, xfs@oss.sgi.com

Christoph Hellwig wrote:
> On Mon, Jun 22, 2009 at 01:01:35PM -0500, Felix Blyakher wrote:
>>> To use it make sure CONFIG_EVENT_TRACING is enabled and then enable  
>>> all
>>> xfs trace channels by:
>>>
>>>   echo 1 > /sys/kernel/debug/tracing/events/xfs/enable
>> Does event tracing work on ia64 platform?
>> I spent some time on it over weekend, but was not able even
>> to force "CONFIG_EVENT_TRACING=y" setting in the .config.
>> Seems to build ok on x86_64, which does have CONFIG_TRACING
>> in defconfig, and allows to set CONFIG_EVENT_TRACING.
> 
> IA64 ftrace support was added earlier this year, but it seems it can't
> be enabled anymore since the big config option reshuffle.  Now tracing
> support requires the architecture to define the TRACE_IRQFLAGS_SUPPORT
> and STACKTRACE_SUPPORT symbols, which seems to be missing on ia64.

Where are we at with this one, I'd like to get this in for XFS but I
agree w/ Felix that throwing out a "working" trace infrastructure w/
nothing to replace it on ia64 would not be great.

Is this just config confusion, or is the functionality actually missing
on ia64?

Thanks,
-Eric
