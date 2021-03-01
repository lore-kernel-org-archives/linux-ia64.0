From: Christoph Hellwig <hch@lst.de>
Date: Mon, 01 Mar 2021 07:53:52 +0000
Subject: Re: [PATCH] mm: Generalize HUGETLB_PAGE_SIZE_VARIABLE
Message-Id: <20210301075352.GA27659@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1614577853-7452-1-git-send-email-anshuman.khandual@arm.com> <20210301062358.GA25761@lst.de> <89f2d77c-f4bc-8f7b-a6b0-1c04e422fb77@arm.com>
In-Reply-To: <89f2d77c-f4bc-8f7b-a6b0-1c04e422fb77@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Mon, Mar 01, 2021 at 01:13:41PM +0530, Anshuman Khandual wrote:
> > doesn't this need a 'if HUGETLB_PAGE'
> 
> While making HUGETLB_PAGE_SIZE_VARIABLE a generic option, also made it
> dependent on HUGETLB_PAGE. Should not that gate HUGETLB_PAGE_SIZE_VARIABLE
> when HUGETLB_PAGE is not available irrespective of the select statement on
> the platforms ?

depends doesn't properly work for variables that are selected.
