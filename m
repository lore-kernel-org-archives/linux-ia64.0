From: Jes Sorensen <jes@sgi.com>
Date: Thu, 22 May 2008 15:23:35 +0000
Subject: Re: [patch] fix zero extending for mmio ld1/2/4 emulation in KVM
Message-Id: <48358FF7.3040003@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4832A0A6.8050800@sgi.com>
In-Reply-To: <4832A0A6.8050800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Xu, Anthony wrote:
>> unnecessary divergence is
>> undesirable. 
> 
> Good point, we should keep kvm/ia64 and xen/ia64 the same code base as
> possible.

It would be nice, but the KVM codebase has already been modified a lot,
just the reformatting in order to be acceptable to the Linux kernel. I
don't think it's realistic to keep them identical.

Cheers,
Jes
