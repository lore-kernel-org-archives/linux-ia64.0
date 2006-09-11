From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 11 Sep 2006 16:18:08 +0000
Subject: Re: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <20060911161808.GA542@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 11, 2006 at 02:12:13PM +0800, Zou Nan hai wrote:
> On Mon, 2006-09-11 at 14:56, Keith Owens wrote:
> > entering ia64_init_handler, r1 must be set to what the kernel expects
> > to be in r1.  The standard kernel's r1 is a region 7 address, not a
> > region 5 address.  The kernel (including __gp) is compiled as region 5
> > but relocated to region 7 during kernel load.
> > 
> > Is the kexec kernel running in region 5?  That may be where the
> > confusion is coming from.
> > 
> Hi Keith,
> 	For 2.6 kernel, I think GP is a region 5 address when inside kernel.
> The entire kernel image is resided in region 5 without relocate to
> region 7. 

Nanhai is right here.  The kernel is linked at region 5
addresses and mapped into physical memory by ITR[0]/DTR[0]

Code in head.S that initializes r1 before we call any C code
is a simple "movl gp=__gp".  Disassembling vmlinux, I see that
became: "movl r1=0xa000000100b6ea80".  Peeking with a debugger
at the running kernel I see a region 5 address in r1.

Perhaps you are remembering the tricks that we play with the
address of "init_task" ... that has truly schizophrenic
existance between region5 and region7 (and our preferred access
address has changed from region7 to region5 as the years have
gone by to make list_structs inside init_task work correctly).

-Tony
