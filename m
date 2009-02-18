From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Wed, 18 Feb 2009 02:17:56 +0000
Subject: RE: [PATCH 01/02] ia64: Move the macro definitions related to MSI
Message-Id: <706158FABBBA044BAD4FE898A02E4BC22422A91C@pdsmsx503.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <706158FABBBA044BAD4FE898A02E4BC2241A31DA@pdsmsx503.ccr.corp.intel.com>
 <57C9024A16AD2D4C97DC78E552063EA361791E04@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA361791E04@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: Avi Kivity <avi@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "kvm-ia64@vger.kernel.org" <kvm-ia64@vger.kernel.org>

Thanks, Tony! It should not break anything due to no changes about code logic. :)

Avi, 
	Could you help to commit the patches with Tony's Ack ? Thanks!
Xiantao


Luck, Tony wrote:
>> For supporting kvm's MSI, we have to move some macros
>> from ia64_msi.c out to avoide duplicate them. In addition,
>> to keep them consistent with x86's , I also changed some
>> macros' name.  How do you think of the patch ?  If you
>> agree to the changes, could you add your Sign-off-by to
>> the patch, and Avi may check-in it to kvm.git first to
>> fix an emergent build issue for kvm/ia64.   Thanks!
> 
> Looks OK to me (I didn't test it, or even build it ... so I hope you
> did!). 
> 
> Acked-by: Tony Luck <tony.luck@intel.com>

