From: Alexander Graf <agraf@suse.de>
Date: Mon, 27 Sep 2010 09:52:55 +0000
Subject: Re: [PATCH] KVM: ia64: define kvm_lapic_enabled() to fix a compile error
Message-Id: <85B08A64-E8BA-4B3C-AB4A-7DC25A673044@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100902175500.ac552016.yoshikawa.takuya@oss.ntt.co.jp> <4C7F6707.7030004@redhat.com> <4CA03EED.9080404@oss.ntt.co.jp> <4CA068C7.3020004@redhat.com>
In-Reply-To: <4CA068C7.3020004@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Avi Kivity <avi@redhat.com>
Cc: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>, Marcelo Tosatti <mtosatti@redhat.com>, KVM list <kvm@vger.kernel.org>, kvm-ia64@vger.kernel.org, linux-ia64@vger.kernel.org


On 27.09.2010, at 11:49, Avi Kivity wrote:

> On 09/27/2010 08:51 AM, Takuya Yoshikawa wrote:
>> (2010/09/02 17:57), Avi Kivity wrote:
>>> On 09/02/2010 11:55 AM, Takuya Yoshikawa wrote:
>>>> The following patch
>>>> 
>>>> commit 57ce1659316f4ca298919649f9b1b55862ac3826
>>>> KVM: x86: In DM_LOWEST, only deliver interrupts to vcpus with enabled LAPIC's
>>>> 
>>>> ignored the fact that kvm_irq_delivery_to_apic() was also used by ia64.
>>>> 
>>>> We define kvm_lapic_enabled() to fix a compile error caused by this.
>>>> This will have the same effect as reverting the problematic patch for ia64.
>>> 
>>> Applied, thanks.
>>> 
>> 
>> Hi,
>> 
>> Isn't this a candidate for 2.6.36?
>> 
>> Though ia64 kvm is in experimental stage and may not be working now, compile
>> errors may be bad for other people who just want to compile ia64 linux.
>> 
> 
> Maybe we should make ia64 kvm depend on CONFIG_BROKEN.
> 
> It has been "experimental" for quite a while.

Ack. We should give people on the IA64 Linux ML a chance to step up on it though. CC'ing them.


Alex

