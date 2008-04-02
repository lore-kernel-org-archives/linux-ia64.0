From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Wed, 02 Apr 2008 02:03:34 +0000
Subject: RE: [kvm-devel] [13/18] KVM:IA64: Add optimization for some virtulization faults V9
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048869@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC0104872C@pdsmsx415.ccr.corp.intel.com> <47F25153.2040004@sgi.com>
In-Reply-To: <47F25153.2040004@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Carsten Otte <cotte@de.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, virtualization@lists.linux-foundation.org

Fixed. Thanks :)

Jes Sorensen wrote:
> Zhang, Xiantao wrote:
>>> From 0d698efed15759b49e78adcef085feda0a14a175 Mon Sep 17 00:00:00
>>> 2001 
>> From: Xiantao Zhang <xiantao.zhang@intel.com>
>> Date: Tue, 1 Apr 2008 14:57:09 +0800
>> Subject: [PATCH] KVM:IA64: Add optimization for some virtulization
>> faults 
>> 
>> optvfault.S Add optimization for some performance-critical
>> virtualization faults. Signed-off-by: Anthony Xu
>> <anthony.xu@intel.com> 
>> Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com> ---
>>  arch/ia64/kvm/optvfault.S |  918
>> +++++++++++++++++++++++++++++++++++++++++++++
>>  1 files changed, 918 insertions(+), 0 deletions(-)
>>  create mode 100644 arch/ia64/kvm/optvfault.S
> 
> Hi Xiantao,
> 
> This one still suffers from the bad indentation.
> 
> Cheers,
> Jes
> 
>
------------------------------------------------------------------------
-
> Check out the new SourceForge.net Marketplace.
> It's the best place to buy or sell services for
> just about anything Open Source.
>
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketp
lace
> _______________________________________________
> kvm-devel mailing list
> kvm-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/kvm-devel

