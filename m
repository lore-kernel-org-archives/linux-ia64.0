From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 05 Aug 2004 21:29:09 +0000
Subject: Re: [Fastboot] Re: [BROKEN PATCH] kexec for ia64
Message-Id: <m18yct2s0q.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <D36CE1FCEFD3524B81CA12C6FE5BCAB00750E615@fmsmsx406.amr.corp.intel.com>
In-Reply-To: <D36CE1FCEFD3524B81CA12C6FE5BCAB00750E615@fmsmsx406.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Cc: Grant Grundler <iod00d@hp.com>, "Randy.Dunlap" <rddunlap@osdl.org>, fastboot@osdl.org, linux-ia64@vger.kernel.org, Jesse Barnes <jbarnes@engr.sgi.com>, linux-kernel@vger.kernel.org

"Tolentino, Matthew E" <matthew.e.tolentino@intel.com> writes:

> >On Wed, Aug 04, 2004 at 08:14:55PM -0600, Eric W. Biederman wrote:
> >> VGA/serial console devices rarely need to do be bus masters so they
> >> should be fine.
> >
> >yeah - you are right. I wasn't thinking.
> >Can anyone comment on UGA or other console devices?
> 
> UGA is essentially a PCI device.  It uses the EFI PCI I/O 
> protocol which gets glued to the kernels pci layer...at least in 
> a prototype.  
> 
> I haven't looked at the latest kexec patch.  How is it handling
> the call to EFI's SetVirtualAddressMap()?  Is it part of the config
> associated with kexec to do efi calls in physical mode only so that
> it doesn't have to contend with potential follow-on invocations 
> resultant from "the next" kernel's initialization?

It should be.  So far all I have seen are tentative ia64 kexec patches.

Eric
