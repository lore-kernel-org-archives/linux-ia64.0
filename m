From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 04 Jun 2004 23:41:05 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <1086392465.24915.151.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1086390257.24915.132.camel@nighthawk>
In-Reply-To: <1086390257.24915.132.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-06-04 at 16:17, Ashok Raj wrote:
> I think your solution can be easily solved if all you want to do is
> "your platform does not support cpuhotplug", which case just dont create 
> for any cpu, or even better dont do anything in register_cpu() related
> to control file creation. Forcing all implementations to behave one way just to 
> do what you want seems not right approach, and limiting all to least common
> denominator.

That's originally what I did.  A single global function to see if the
platform supported cpu hotplug at runtime.  The addition of passing the
'struct cpu' to it was so trivial that I figured it might be useful to
someone down the line.  I'm regretting my "foresight" now :)

> The preferable way to this would be.
> 
> - platfform_supports_cpuhotplug(), like in your case, dont create the 
>   online file for any.
> - __cpu_is_hotpluggable(cpu#) can also exist if this is a static decision to 
>    be made, say if the platform says that a certain cpu cannot be removed. 

That seems to be a pretty sensible way to do it.  However, we keep the
number of interfaces from generic to arch code down if we keep the
interface confined to 1 function.  It would be trivial to make any
architecture that needs it do this:

int __cpu_is_hotpluggable(struct cpu *cpu)
{
	if (!platfform_supports_cpuhotplug())
		return 0;

	lots();
	of_complex_arch_code();
	here();
	...
}

That ensures that there's only 1 function that needs to be defined
globally: __cpu_is_hotpluggable().

But, I definitely see the merit in what you want.

> But you should not always assume this is a static decision just because its the
> case in one platform. In my earlier example, if you have 8 cpu system, 
> but cpu0-3 are special, and atleast 1 needs to exist for the system to work.
> 
> I can remove any of of cpu0-3 until i have atleast one  of the cpu0-3 left. The
> last one is not removable.
> 
> Keep it simple please:-)

That's what I'm trying to to :)

I was thinking that cpuX/online is only there to say whether hotplug
_operations_ are supported on the cpu, not if it can be hotplugged right
now.  The "can currently be hotplugged" question is another can of worms
that can't really be answered until the hotplug request is made anyway,
so I'd prefer to keep from trying to decide that by the presence of the
file.

The purpose of the patch is originally only to keep ppc64 systems from
making firmware calls that they couldn't support.  (Someone tried to
offline a CPU on a system when it wasn't supported and the firmware got
mad)

-- Dave

