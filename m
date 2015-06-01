From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Mon, 01 Jun 2015 07:35:57 +0000
Subject: Re: [PATCH 0/5] Remove s390 sw-emulated hugepages and cleanup
Message-Id: <556C0B5D.40205@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Am 28.05.2015 um 13:52 schrieb Dominik Dingel:
> Hi everyone,
> 
> there is a potential bug with KVM and hugetlbfs if the hardware does not
> support hugepages (EDAT1).
> We fix this by making EDAT1 a hard requirement for hugepages and 
> therefore removing and simplifying code.

The cleanup itself is nice and probably the right thing to do. 
Emulating large pages makes the code more complex and asks for
trouble (as outlined above)

The only downside that I see is that z/VM as of today does not
announce EDAT1 for its guests so the "emulated" large pages for
hugetlbfs would be useful in that case. The current code allocates
the page table only once and shares it for all mappers - which is
useful for some big databases that spawn hundreds of processes with
shared mappings of several hundred GBs. In these cases we do save
a decent amount of page table memory. 

Not sure if that case is actually important, though.

Christian

