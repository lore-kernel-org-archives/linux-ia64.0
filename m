From: Avi Kivity <avi@redhat.com>
Date: Sun, 20 Dec 2009 08:27:39 +0000
Subject: Re: [PATCH] Fix kvm build for ia64
Message-Id: <4B2DDFFB.2060807@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4b2ad53f6113bd0d@agluck-desktop.sc.intel.com>
In-Reply-To: <4b2ad53f6113bd0d@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 12/18/2009 03:05 AM, Luck, Tony wrote:
> Len Brown pointed out that allmodconfig is broken for
> ia64 because of:
>
> arch/ia64/kvm/vmm.c: In function 'vmm_spin_unlock':
> arch/ia64/kvm/vmm.c:70: error: 'spinlock_t' has no member named 'raw_lock'
>
> KVM has it's own spinlock routines. It should not depend on the base kernel
> spinlock_t type (which changed when ia64 switched to ticket locks).  Define
> its own vmm_spinlock_t type.
>    

Applied and queued for 2.6.33.  Thanks.

-- 
error compiling committee.c: too many arguments to function

