From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 30 Mar 2005 11:14:39 +0000
Subject: Re: [PATCH] Pageset Localization V2
Message-Id: <20050330111439.GA13110@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503292147200.32571@server.graphe.net>
In-Reply-To: <Pine.LNX.4.58.0503292147200.32571@server.graphe.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <christoph@lameter.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, shai@scalex86.org

> +#define MAKE_LIST(list, nlist)  \
> +	do {    \
> +		if(list_empty(&list))      \
> +			INIT_LIST_HEAD(nlist);          \
> +		else {  nlist->next->prev = nlist;      \
> +			nlist->prev->next = nlist;      \
> +		}                                       \
> +	}while(0)

This is horrible.  Where are the nlist pointers supposed to point to?
What's so magic you need the INIT_LIST_HEAD only conditionally?

