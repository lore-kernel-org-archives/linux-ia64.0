From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Sat, 29 May 2004 00:57:33 +0000
Subject: RE: [PATCH] don't udelay() in sn_mmiob
Message-Id: <01EF044AAEE12F4BAAD955CB750649430195EA36@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405261749.02254.jbarnes@engr.sgi.com>
In-Reply-To: <200405261749.02254.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack Steiner <> wrote on Friday, May 28, 2004 10:35 AM:

> On Fri, May 28, 2004 at 12:28:55PM -0500, Jack Steiner wrote:
>> On Thu, May 27, 2004 at 05:06:31PM -0400, Jesse Barnes wrote:
>>> On Thursday, May 27, 2004 4:46 pm, David Mosberger wrote:
>>>> Wouldn't you want at least a cpu_relax() in that loop?
>>> 
>>> That'll cause the CPU to switch to the other thread if it's SMT so
>>> it won't spin waiting for the access to complete?  If so, then yes.
>>> Here's an updated patch.
> 
> Whoops, I posted this response to the wrong mail. I was replying to
> the question about whether the code should have a "cpu_relax()". 
> 
>> 
>> I didn't think the code would actually spin.
>> 
>> sn_mmiob() is something like:
>> 
>>     1:	ld.acq r8=...
>>     	;;
>> 	cmp.eq p8,p0=r8,r9
>>    (p8)	br 1b
>> 
>> The "load" is an uncached load. Won't the pipeline stall on the cmp
>> waiting for data to arrive. I would not have expected that a
>> cpu_relax() would have been needed here.
>> 

You are right that pipeline will stall on the cmp instruction.  But if
you could put the hint@pause between ld and cmp instructions then that
would allow current execution stream to give up resources to other
execution stream (if applicable) for the time that data takes to come
from main memory.

-rohit

