From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 17 May 2004 05:31:56 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <1084771915.24128.4931.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-05-13 at 17:13, Yasunori Goto wrote:
> > At some point, questions such as "what happens when a node is unplugged
> > from a cpuset" will need to be answered.  And even earlier, "what happens
> > when a cpu is unplugged that was in a tasks cpus_allowed, or a memory
> > node unplugged, that was in a vma's list of allowed memory zones."
> > 
> > Or perhaps the answers to these questions are already known ??
> 
> At least, there aren't enough answer about memory hotplug yet
> if there is a process that is using memory affinity.

There's been a lot of talk of what to do with hotplug CPUs as well.  No
matter what, it's going to be really easy to notify whatever app you
want with the hotplug scripts whenever a memory or CPU event happens. 
Just place your app script in /etc/hotplug.d.

-- Dave

