From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 30 Jan 2002 06:54:10 +0000
Subject: Re: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805955@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 30, 2002 at 05:46:45PM +1100, duraid@fl.net.au wrote:
> No flops in this code!
> 
Sometimes, the compiler uses floating point register for integer
operations for speed reason.

> > Another potential cause could be unaligned accesses. That you can also see 
> > in the system log.
> 
> 'dmesg' works and sure enough, I get unaligned accesses. But not enough to get
> *that* sort of a performance hit, surely? To explain what I'm seeing, each
> unaligned access would have to cost 0.05 seconds or so!

The kernel DOES NOT generate a printk() for every unaligned accesses you
get, it's throttled. Get the address from the syslog  and check the code.
You may be casting ints into pointers. Linux/ia64 uses the LP64 data
model: long and pointers are 64 bits but int are 32 bits only. 

-- 
-Stephane

