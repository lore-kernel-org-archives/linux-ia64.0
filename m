From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 02 Aug 2007 04:27:51 +0000
Subject: [RFC][PATCH 0/2] SN platform needs platform_irq_to_vector?
Message-Id: <1186028871.3875.12.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jes-san, Russ-san, Christoph-san and SN platform developers,

I glanced over the SN code, and I found SN platform doesn't have SN
specific irq_to_vector() function, though it has SN specific
local_vector_to_irq() function. I guess it was OK because maybe SN
platform depends on irq = vector and old generic irq_to_vector() was
just returning the same value as irq.

The irq_to_vector() function, however, has been changed by vector
domain support, and currently it can return the different value from
irq, even when VECTOR_DOMAIN_PERCPU is not enabled. This can happen
when an interrupt thorough I/O SAPIC is unregistered and another
interupt is registered. So if my guess (SN platform depends on irq =
vector) is true, something problem might happen on SN platform when
PCI hotplugging or driver reloading.

If it is true that SN platform depends on irq = vector, we need to
implement SN specific irq_to_vector() that returns the same value as
irq, I think. I made sample patches to implement platform specific
irq_to_vector() as follows. Note that [PATCH 2/2] is not tested yet
because I don't have any SN platform unfortunately.

    [PATCH 1/2] Add base support for platform_irq_to_vector()
    [PATCH 2/2] Implement platform_irq_to_vector() for SN

Could you give me comments?

Thanks,
Kenji Kaneshige


