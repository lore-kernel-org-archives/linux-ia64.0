From: Ashok Raj <ashok.raj@intel.com>
Date: Sat, 05 Jun 2004 14:38:02 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <20040605073802.A22026@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1086390257.24915.132.camel@nighthawk>
In-Reply-To: <1086390257.24915.132.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 04, 2004 at 04:41:05PM -0700, Dave Hansen wrote:
> 
> That's originally what I did.  A single global function to see if the
> platform supported cpu hotplug at runtime.  The addition of passing the
> 'struct cpu' to it was so trivial that I figured it might be useful to
> someone down the line.  I'm regretting my "foresight" now :)
> 
> > The preferable way to this would be.
> > 
> > - platfform_supports_cpuhotplug(), like in your case, dont create the 
> >   online file for any.
> > - __cpu_is_hotpluggable(cpu#) can also exist if this is a static decision to 
> >    be made, say if the platform says that a certain cpu cannot be removed. 
> 
> That seems to be a pretty sensible way to do it.  However, we keep the
> number of interfaces from generic to arch code down if we keep the
> interface confined to 1 function.  It would be trivial to make any
> architecture that needs it do this:
> 
> int __cpu_is_hotpluggable(struct cpu *cpu)
> {
> 	if (!platfform_supports_cpuhotplug())
> 		return 0;
> 
> 	lots();
> 	of_complex_arch_code();
> 	here();
> 	...
> }
> 
> That ensures that there's only 1 function that needs to be defined
> globally: __cpu_is_hotpluggable().
> 

I feel the __cpu_disable() should be just sufficient to be the only
function interface from generic to arch code. You run this
__cpu_is_hotpluggable(cpu) only in ppc64, where you check and return error.
maybe also printing to console saying the platform doesnt support it.

you are adding an extra arch function just for a trivial thing, not to create a 
control file. 

> > 
> > Keep it simple please:-)
> 
> That's what I'm trying to to :)
> 
> I was thinking that cpuX/online is only there to say whether hotplug
> _operations_ are supported on the cpu, not if it can be hotplugged right
> now.  The "can currently be hotplugged" question is another can of worms
> that can't really be answered until the hotplug request is made anyway,
> so I'd prefer to keep from trying to decide that by the presence of the
> file.
My recommendation is to not do anything, and just let __cpu_disable() handle it.
print some verbose message for the operator that this aint going to work should
be more than sufficient. There is not a whole lot of realusefullness for this 
to work.

we if overdo something here, then memory hotplug, node hotplug would all need
to do the same hack, __is_node_hotpluggable(node), is_memsection_hotpluggabe(mem)
and so on....

Cheers,
ashok
