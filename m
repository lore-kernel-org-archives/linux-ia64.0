From: Ashok Raj <ashok.raj@intel.com>
Date: Fri, 04 Jun 2004 23:17:50 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <20040604161749.A15628@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1086390257.24915.132.camel@nighthawk>
In-Reply-To: <1086390257.24915.132.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 04, 2004 at 04:04:17PM -0700, Dave Hansen wrote:

Dave,

I think your solution can be easily solved if all you want to do is
"your platform does not support cpuhotplug", which case just dont create 
for any cpu, or even better dont do anything in register_cpu() related
to control file creation. Forcing all implementations to behave one way just to 
do what you want seems not right approach, and limiting all to least common
denominator.

The preferable way to this would be.

- platfform_supports_cpuhotplug(), like in your case, dont create the 
  online file for any.
- __cpu_is_hotpluggable(cpu#) can also exist if this is a static decision to 
   be made, say if the platform says that a certain cpu cannot be removed. 

But you should not always assume this is a static decision just because its the
case in one platform. In my earlier example, if you have 8 cpu system, 
but cpu0-3 are special, and atleast 1 needs to exist for the system to work.

I can remove any of of cpu0-3 until i have atleast one  of the cpu0-3 left. The
last one is not removable.

Keep it simple please:-)

Cheers,
ashok
> On Fri, 2004-06-04 at 15:49, Ashok Raj wrote:
> > place a file in /sys/devices/system/cpuinfo, which when one does a cat on
> > can display
> > 
> > cpu0:	online, not offlinable
> > cpu1:	online
> > cpu2:	offline (meaning present)
> 
> This might be a little bit more than is intended for a sysfs file,
> especially if the information can be obtained some other way.  Here's
> what I was thinking of:
> 
> cat /sys/devices/system/cpu/cpuX/online
> doesn't exist: online, not offlinable
> 	    1: online
> 	    0: offline (meaning present)
> 
> If you want to get information like you have above, it's pretty trivial
> to write a little script to do it.  
> 
> > the reason this cannot be determined at early time, is say if a set of cpu's are
> > in a special mode, i.e only those 4 cpu's can retrieve a set of platform registers.
> > for error processing. And i can offline each of those, until i run into the last 
> > of those 4 cpus. 
> 
> Are you saying that you don't know if a CPU can be offlined at the time
> that the sysfs files are created?  If so, I bet we could delay the
> creation of the kobjects until a more appropriate time.  I don't think
> anything in early boot actually needs them.
> 
> > I would prefer to not have a macro to preventy its creation, but have a 
> > facility to know the offlineable status via a single information file, and 
> > let __cpu_disable() determine if offline should fail based on current ability 
> > to offline a cpu.
> > 
> > what do you think?
> 
> I just worry that any single information file doesn't fit in well with
> the sysfs model.  
> 
> -- Dave
> 
