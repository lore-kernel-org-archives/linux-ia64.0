From: Jack Steiner <steiner@sgi.com>
Date: Mon, 03 Nov 2003 18:23:04 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106788385832064@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 03, 2003 at 06:37:37PM +0100, Matthias Fouquet-Lapar wrote:
> > For example, in the case of an application hitting a memory 
> > uncorrectable on a multi-processor system, the MCA will be handled 
> > by PAL and SAL.  If SAL can determine the failing HW physical address,
> > it could pass that information up to linux.  Linux could look at the
> > physical address and figure out which application has that address
> > mapped and kill the application, without crashing the system.  Linux
> > should also not allow that physical memory to be reused by any other
> > process.
> 
> Hi,
> 
> I just wondered if a speculative load hitting a cache or memory
> error does cause an exception on IA64 ? 

I dont think a speculative load should cause a problem - at least until 
code tries to consume the data by transfering it to a processor register.

As I understand the cpu architecture, an error that occurs reading data
will result in a poisoned cache line being delivered to the cpu cache. 
The poisoned cache line can stay in the cache forever. No MCA error is
reported until the data is actually consumed by tranfering the data from 
cache to a cpu register. 

This requires some support from the chipset. Some chipsets dont fully
support this error model.




-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


