From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Mon, 03 Nov 2003 17:37:37 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106788161128620@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> For example, in the case of an application hitting a memory 
> uncorrectable on a multi-processor system, the MCA will be handled 
> by PAL and SAL.  If SAL can determine the failing HW physical address,
> it could pass that information up to linux.  Linux could look at the
> physical address and figure out which application has that address
> mapped and kill the application, without crashing the system.  Linux
> should also not allow that physical memory to be reused by any other
> process.

Hi,

I just wondered if a speculative load hitting a cache or memory
error does cause an exception on IA64 ? 

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

