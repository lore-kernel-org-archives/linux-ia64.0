From: Dave Hansen <haveblue@us.ibm.com>
Date: Sat, 05 Jun 2004 19:22:21 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <1086463340.30138.58.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1086390257.24915.132.camel@nighthawk>
In-Reply-To: <1086390257.24915.132.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 2004-06-05 at 07:38, Ashok Raj wrote:
> I feel the __cpu_disable() should be just sufficient to be the only
> function interface from generic to arch code. You run this
> __cpu_is_hotpluggable(cpu) only in ppc64, where you check and return error.
> maybe also printing to console saying the platform doesnt support it.

Actually __cpu_is_hotpluggable(cpu) does get called on ia64, it's just a
trivially-defined 'return 1' for now.  Are there ever any plans to run
an kernel with CONFIG_HOTPLUG_CPU on an ia64 machine that doesn't really
support cpu hotplug?  If so, I'd be happy to include the same
functionality on ia64 that I put for ppc64.

BTW, the reason that this is done on ppc64 is that we can run the same
kernel on a wide variety of hardware, so it makes the distributions'
jobs a bit easier.  

> you are adding an extra arch function just for a trivial thing, not to create a 
> control file. 
...
> My recommendation is to not do anything, and just let __cpu_disable() handle it.
> print some verbose message for the operator that this aint going to work should
> be more than sufficient. There is not a whole lot of realusefullness for this 
> to work.

The non-trivial thing that this patch tries to do is give the user some
knowledge about the system from the pure layout of sysfs.  Waiting until
__cpu_disable() to tell the user that there was no possibility of the
cpu being offlined seems a bit late in the process.  Your idea about the
cpuinfo file in sysfs is definitely right; it has *exactly* the
information that I'm trying to present.  But, the current sysfs
guidelines tend to discourage single files with lots of information like
those in /proc.  

-- Dave

