From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 29 Mar 2005 12:22:42 +0000
Subject: Re: [PATCH 3/91] get rid of pci_find_{device,subsys} arch/ia64
Message-Id: <20050329122242.GA26755@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 29, 2005 at 05:50:09PM +0530, Amit Gud wrote:
> Replace pci_find_{device,subsys} with pci_get_{device,subsys}.

should be for_each_pci_dev

