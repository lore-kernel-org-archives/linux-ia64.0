From: Russ Anderson <rja@sgi.com>
Date: Mon, 03 Nov 2003 17:09:11 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106787982226219@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler wrote:
On Fri, Oct 31, 2003 at 02:09:12PM +0900, Hidetoshi Seto wrote:
>> In the case of platform premising IPF, I think it is
>> better to regard the Intel's Chipset as the de facto
>> standard.
>
> hmm...given ia64 intel boxes I've played with have no error containment
> and softfail on everything, I'm not sure that's a good choice.
> Or has enough been published about the chipset to change those
> behaviors?

There are some errors on ia64 that are recoverable, with the right
SW (PAL,SAL,Linux) and chipset support.  

There are some errors on ia64 that are not recoverable, but hopefully
will be in newer cpu & chipset versions.

A Matthias points out, some of the recovery should abstracted out 
in linux to hide the underlying hardware implementation.  

For example, in the case of an application hitting a memory 
uncorrectable on a multi-processor system, the MCA will be handled 
by PAL and SAL.  If SAL can determine the failing HW physical address,
it could pass that information up to linux.  Linux could look at the
physical address and figure out which application has that address
mapped and kill the application, without crashing the system.  Linux
should also not allow that physical memory to be reused by any other
process.

Part of that recovery is platform specific (HW, PAL, SAL) but
part of it is platform independent (linux converting the physical
address, shooting the app, page handling).

As for IPF being "the defacto standard", IPF is certainly the
platform I'm interested in (hence posting to linux-ia64), but others 
will have their own preference.  The platform independent parts of 
linux should have interfaces designed to work on any platform (duh).  
Actual implementation will likely be done on several different 
architectures.  

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
