From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 04 Jun 2004 23:04:17 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <1086390257.24915.132.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-06-04 at 15:49, Ashok Raj wrote:
> place a file in /sys/devices/system/cpuinfo, which when one does a cat on
> can display
> 
> cpu0:	online, not offlinable
> cpu1:	online
> cpu2:	offline (meaning present)

This might be a little bit more than is intended for a sysfs file,
especially if the information can be obtained some other way.  Here's
what I was thinking of:

cat /sys/devices/system/cpu/cpuX/online
doesn't exist: online, not offlinable
	    1: online
	    0: offline (meaning present)

If you want to get information like you have above, it's pretty trivial
to write a little script to do it.  

> the reason this cannot be determined at early time, is say if a set of cpu's are
> in a special mode, i.e only those 4 cpu's can retrieve a set of platform registers.
> for error processing. And i can offline each of those, until i run into the last 
> of those 4 cpus. 

Are you saying that you don't know if a CPU can be offlined at the time
that the sysfs files are created?  If so, I bet we could delay the
creation of the kobjects until a more appropriate time.  I don't think
anything in early boot actually needs them.

> I would prefer to not have a macro to preventy its creation, but have a 
> facility to know the offlineable status via a single information file, and 
> let __cpu_disable() determine if offline should fail based on current ability 
> to offline a cpu.
> 
> what do you think?

I just worry that any single information file doesn't fit in well with
the sysfs model.  

-- Dave

