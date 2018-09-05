From: Rob Herring <robh@kernel.org>
Date: Wed, 05 Sep 2018 17:04:36 +0000
Subject: Re: [RFC PATCH 07/29] memblock: remove _virt from APIs returning virtual address
Message-Id: <CABGGiswdb1x-=vqrgxZ9i2dnLdsgtXq4+5H9Y1JRd90YVMW69A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com> <1536163184-26356-8-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1536163184-26356-8-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rppt@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, mingo@redhat.com, Michael Ellerman <mpe@ellerman.id.au>, mhocko@suse.com, paul.burton@mips.com, Thomas Gleixner <tglx@linutronix.de>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Sep 5, 2018 at 11:00 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
>
> The conversion is done using
>
> sed -i 's@memblock_virt_alloc@memblock_alloc@g' \
>         $(git grep -l memblock_virt_alloc)

What's the reason to do this? It seems like a lot of churn even if a
mechanical change.

Rob
