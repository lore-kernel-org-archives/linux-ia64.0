From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 25 Jan 2008 01:18:51 +0000
Subject: RE: [kvm-devel] ia64 kernel patches?
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCCE708C@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4798C34F.9010509@sgi.com> <20080124185316.GW3627@sequoia.sous-sol.org>
In-Reply-To: <20080124185316.GW3627@sequoia.sous-sol.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: Chris Wright <chrisw@sous-sol.org>, Jes Sorensen <jes@sgi.com>
Cc: kvm-devel@lists.sourceforge.net, "Xu, Anthony" <anthony.xu@intel.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org

Hi, Jes
Yes, Anthony and I are working with kernel-ia64 and kvm community to push the patches. Since kernel should export some interface for kvm use, we have to wait the response from kernel-ia64. But anyway,  It should be picked up in near future. :)  Compared with last push, we added smp guest support and got more stable status now . 
Thanks
Xiantao

-----Original Message-----
From: Chris Wright [mailto:chrisw@sous-sol.org] 
Sent: 2008年1月25日 2:53
To: Jes Sorensen
Cc: Zhang, Xiantao; kvm-devel@lists.sourceforge.net
Subject: Re: [kvm-devel] ia64 kernel patches?

* Jes Sorensen (jes@sgi.com) wrote:
> Trying to browse the list archives, but both gmane and sourcefrog's
> interfaces are really painful to deal with.
> 
> So, any chance someone could point me at the current ia64 KVM kernel
> patches? I notice they are not yet in Avi's tree.

The last full round of patches I recall are from December.
Maybe better to get updated patches from Xiantao?

thanks,
-chris
