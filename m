From: duraid@fl.net.au
Date: Wed, 30 Jan 2002 09:36:48 +0000
Subject: Re: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805960@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Quoting Stephane Eranian <eranian@frankl.hpl.hp.com>:

> On Wed, Jan 30, 2002 at 05:46:45PM +1100, duraid@fl.net.au wrote:
> > No flops in this code!
> > 
> Sometimes, the compiler uses floating point register for integer
> operations for speed reason.

Granted, but (God willing) nobody will ever encounter a compiler crazy enough 
to emit FP code that needs software assistance!

> The kernel DOES NOT generate a printk() for every unaligned accesses you
> get, it's throttled.

That's what my intuition told me. But the sysadmin assured me that the opposite 
was true. Bad sysadmin.

> You may be casting ints into pointers. Linux/ia64 uses the LP64 data
> model: long and pointers are 64 bits but int are 32 bits only. 

#@!%#@!% (I knew that already, but !#%#@%#%) Is it just an urban myth, or was 
it once declared upon high that longs shall always be 32 bits, long longs shall 
always be 64 bits, and ints shall be Whatever Length Is Most Efficiently Dealt 
With By The Hardware(tm)?

Whoever chose LP64 should be sent to Guantanamo Bay for some "those blindfolds 
are for their own safety" interrogation!

     Duraid


