From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 18 Feb 2008 03:52:30 +0000
Subject: RE: paravirt_ops support in IA64
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCDF2356@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10EA09EFD8728347A513008B6B0DA77A02C8234B@pdsmsx411.ccr.corp.intel.com>
In-Reply-To: <10EA09EFD8728347A513008B6B0DA77A02C8234B@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dong, Eddie wrote:
> 
> 	In X86, there are another enhancement (dynamic patching) base on
> pv_ops. The purpose is to improve cpu predication by converting
> indriect function call to direct function call for both C & ASM code.
> We may take similar approach some time later too.   
> 
> 	We really need advices from community before we jump into
coding.
> 	CC some active members that I though may be interested in pv_ops
> since KVM-IA64 mailinglist doesn;t exist yet. 

Hi, Eddie

we just created the kvm-ia64-devel mailing list, and cc to the guys from
this list who maybe interested in this topic. 
If you or other guys who are interested in kvm-ia64-devel or pv_virt_ops
for ia64, please subscribe it here

http://kvm.qumranet.com/kvmwiki/Lists%2C_IRC

Xiantao


