From: Zou Nan hai <nanhai.zou@intel.com>
Date: Tue, 15 Aug 2006 22:40:20 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <1155681620.2585.74.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-08-16 at 01:39, Bob Montgomery wrote:
> On Tue, 2006-08-15 at 08:47 +0800, Zou Nan hai wrote:
> > > ...
> >   Jay,  
> >         Thanks very much, please try the following updated patch which
> > simplify the device_shootdown code.
> > 
> 
> My system continues to hang with the new patch.  I can get a printk just
> before jumping to the new code in machine_kexec.  We're going to try
> hooking up the ITP now.
> 
> Bob Montgomery

  If you are not seeing "I am in purgatory" in console, that probably
means crash kernel segments and purgatory code was copied into some
wrong physical address.

  Can you check the crashkernel="..." parameter
  Thanks

Zou Nan hai
