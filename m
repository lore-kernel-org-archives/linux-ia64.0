From: Amit Gud <gud@eth.net>
Date: Tue, 29 Mar 2005 14:18:17 +0000
Subject: Re: [PATCH 3/91] get rid of pci_find_{device,subsys} arch/ia64
Message-Id: <424960D9.60908@eth.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050329122242.GA26755@infradead.org>
In-Reply-To: <20050329122242.GA26755@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Hellwig wrote:
> On Tue, Mar 29, 2005 at 05:50:09PM +0530, Amit Gud wrote:
> 
>>Replace pci_find_{device,subsys} with pci_get_{device,subsys}.
> 
> 
> should be for_each_pci_dev
> 

Yes, will address such replacements seperately.


Thanks,
AG
--
May the source be with you.
