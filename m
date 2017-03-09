From: Rob Landley <rob@landley.net>
Date: Thu, 09 Mar 2017 04:16:49 +0000
Subject: Re: [PATCH 1/3] futex: remove duplicated code
Message-Id: <23e5808b-2a20-518d-b49a-4d95dd23cfde@landley.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170303122712.13353-1-jslaby@suse.cz>
 <20170304130550.GT21222@n2100.armlinux.org.uk>
In-Reply-To: <20170304130550.GT21222@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@armlinux.org.uk>, Jiri Slaby <jslaby@suse.cz>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

On 03/04/2017 07:05 AM, Russell King - ARM Linux wrote:
> On Fri, Mar 03, 2017 at 01:27:10PM +0100, Jiri Slaby wrote:
>> diff --git a/kernel/futex.c b/kernel/futex.c
>> index b687cb22301c..c5ff9850952f 100644
>> --- a/kernel/futex.c
>> +++ b/kernel/futex.c
>> @@ -1457,6 +1457,42 @@ futex_wake(u32 __user *uaddr, unsigned int flags, int nr_wake, u32 bitset)
>>  	return ret;
>>  }
>>  
>> +static int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
>> +{
>> +	int op = (encoded_op >> 28) & 7;
>> +	int cmp = (encoded_op >> 24) & 15;
>> +	int oparg = (encoded_op << 8) >> 20;
>> +	int cmparg = (encoded_op << 20) >> 20;
> 
> Hmm.  oparg and cmparg look like they're doing these shifts to get sign
> extension of the 12-bit values by assuming that "int" is 32-bit -
> probably worth a comment, or for safety, they should be "s32" so it's
> not dependent on the bit-width of "int".

I thought Linux depended on the LP64 standard for all architectures?

Standard: http://www.unix.org/whitepapers/64bit.html
Rationale: http://www.unix.org/version2/whatsnew/lp64_wp.html

So int has a defined bit width (32) on linux?

Rob
