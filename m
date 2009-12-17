From: Avi Kivity <avi@redhat.com>
Date: Thu, 17 Dec 2009 08:21:33 +0000
Subject: Re: kvm-ia64 spinlocks
Message-Id: <4B29EA0D.7040709@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 12/17/2009 02:07 AM, Luck, Tony wrote:
> [resend with fixed vger address :-) ]
>
> Len Brown pointed out that allmodconfig is broken for
> ia64 because of:
>
> arch/ia64/kvm/vmm.c: In function 'vmm_spin_unlock':
> arch/ia64/kvm/vmm.c:70: error: 'spinlock_t' has no member named 'raw_lock'
>
> This is fall-out from the ia64 switch to ticket locks.
>
> I'm not sure why KVM needs to implement its own locking
> mechanisms ... if it does need to roll its own, it should
> not depend on the base kernel spinlock_t type.

It does, parts of the ia64 vmm run in guest context.

> One possible
> solution is to just have KVM define its own vmm_spinlock_t
> type (see patch below).
>
>    

Looks good.  Changelog/signoff?

> Or perhaps this code needs to implement ticket locks?
>    

This will do for now, I believe.



-- 
error compiling committee.c: too many arguments to function

