From: shobhit dayal <shobhit@calsoftinc.com>
Date: Wed, 30 Mar 2005 12:38:25 +0000
Subject: Re: Fwd: [PATCH] Pageset Localization V2
Message-Id: <1112187977.9773.15.camel@kuber>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503292147200.32571@server.graphe.net>
	 <20050330111439.GA13110@infradead.org>
	 <bab4333005033003295f487e3d@mail.gmail.com>
In-Reply-To: <bab4333005033003295f487e3d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hch@infradead.org
Cc: christoph@lameter.com, manfred@colorfullife.com, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Shai Fultheim <shai@scalex86.org>

The goal here is to replace the head of a existing list pointed to by
'list' with a new head pointed to by 'nlist'. 
First there is a memcpy that copies the contents of list to nlist then
this macro is called.
The macro makes sure that if the old head was empty then INIT_LIST_HEAD
the 'nlist', if not then make sure that the nodes before and after the
head now correclty point to nlist instead of list.

regards
shobhit


> ---------- Forwarded message ----------
> From: Christoph Hellwig <hch@infradead.org>
> Date: Wed, 30 Mar 2005 12:14:39 +0100
> Subject: Re: [PATCH] Pageset Localization V2
> To: Christoph Lameter <christoph@lameter.com>
> Cc: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton
> <akpm@osdl.org>, linux-kernel@vger.kernel.org,
> linux-ia64@vger.kernel.org, linux-mm@kvack.org, shai@scalex86.org
> 
> 
> > +#define MAKE_LIST(list, nlist)  \
> > +     do {    \
> > +             if(list_empty(&list))      \
> > +                     INIT_LIST_HEAD(nlist);          \
> > +             else {  nlist->next->prev = nlist;      \
> > +                     nlist->prev->next = nlist;      \
> > +             }                                       \
> > +     }while(0)
> 
> This is horrible.  Where are the nlist pointers supposed to point to?
> What's so magic you need the INIT_LIST_HEAD only conditionally?
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

