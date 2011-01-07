From: Michel Lespinasse <walken@google.com>
Date: Fri, 07 Jan 2011 12:16:49 +0000
Subject: Re: Very large memory configurations: > 16 TB
Message-Id: <AANLkTik_cTS629Ag+jmkJV+M6auEnu0r17EGZ8nXXBj1@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110106170942.GA8253@sgi.com>
In-Reply-To: <20110106170942.GA8253@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org, mingo@elte.hu, linux-ia64@vger.kernel.org

On Thu, Jan 6, 2011 at 9:09 AM, Jack Steiner <steiner@sgi.com> wrote:
> SGI is currently developing an x86_64 system with more than 16TB of memory per
> SSI. As far as I can tell, this should be supported. The relevant definitions
> such as MAX_PHYSMEM_BITS appear ok.
>
> One area of concern is page counts. Exceeding 16TB will also exceed MAX_INT
> page frames. The kernel (at least in all places I've found) keep pagecounts
> in longs.
>
> Have I missed anything? Should this > 16TB work? Are there any kernel problems or
> problems with user tools that anyone knows of.
>
> Any help or pointers to potential problem areas would be appreciated...

I don't know of any place that uses ints to count physical pages.
However, the page_referenced functions in mm/rmap.c return reference
counts as an integer. I believe a wraparound would only mislead the
LRU algorithms, but I haven't thought about it much. (Not sure why we
return a count anyway, since I believe callers only want to compare it
against zero ???)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
