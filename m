From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:57:04 +0000
Subject: RE: [kvm-ia64-devel] kvm-ia64.git is created on master.kernel.org!
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCF1BBC3@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCF1BB8F@pdsmsx415.ccr.corp.intel.com> <DC8842D6FBC90takebe_akio@jp.fujitsu.com>
In-Reply-To: <DC8842D6FBC90takebe_akio@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akio Takebe <takebe_akio@jp.fujitsu.com>, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org
Cc: kvm-devel@lists.sourceforge.net, "Xu, Anthony" <anthony.xu@intel.com>, Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>

Akio Takebe wrote:
> Hi, Xiantao
> 
>> We have created kvm-ia64.git on master.kernel.org for open
>> development, and the latest source is also included in this
>> repository. So you can clone  and make  contributions to it now. 
>> Cheers!! 
>> In this repository, I created the branch kvm-ia64-mc4 to hold the
>> patchset.  Now, the whole community had better work on the branch
>> together for reviewing code, doing cleanup, and adding the new
>> features. If you have any contribution or questions, please feel
>> free to submit to the kvm-ia64 mailing
>> list(https://lists.sourceforge.net/lists/listinfo/kvm-ia64-devel). 
> Wow, greate!
> Can we use the same userspace tree as x86?

Yes, but seems it is broken for ia64 side due to latest merge with qemu
upstream. 

> Are save/restore already available?

It needs userspace patch. I enabled save&restore without log dirty
mechanism, but it breaks after adding log dirty.  So need more debug
effort on it. 

Xiantao

