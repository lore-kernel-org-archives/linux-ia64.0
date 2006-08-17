From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 17 Aug 2006 03:56:16 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <1155786976.2585.97.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2006-08-17 at 02:25, Bob Montgomery wrote:
> On Wed, 2006-08-16 at 06:40 +0800, Zou Nan hai wrote:
> > On Wed, 2006-08-16 at 01:39, Bob Montgomery wrote:
> > > On Tue, 2006-08-15 at 08:47 +0800, Zou Nan hai wrote:
> 
> > 
> >   If you are not seeing "I am in purgatory" in console, that probably
> > means crash kernel segments and purgatory code was copied into some
> > wrong physical address.
> > 
> >   Can you check the crashkernel="..." parameter
> >   Thanks
> 
> Today, we have had success by changing the configuration of our kernels
> from zx1 to tiger.  Now we'll try to figure out what it is about the zx1
> config parameters that causes the crash_kexec path to break.
> 
> Bob Montgomery
Hi Bob,
	Could you take a look at the ioc_iova_disable code in crash path?

That piece of code is from HP. 
It will only execute if CONFIG_IA64_HP_ZX1 is defined.

I don't have much knowledge of the I/O MMU stuff on HP machines....   	

Thanks
Zou Nan hai
