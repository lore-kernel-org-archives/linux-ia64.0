From: Mario Smarduch <cms063@email.mot.com>
Date: Tue, 27 Apr 2004 22:35:10 +0000
Subject: Re: cacheble to uncachble change
Message-Id: <408EE01E.42630BD8@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> >>>>> On Tue, 27 Apr 2004 16:31:57 -0500, Jack Steiner <steiner@sgi.com> said:
>
>   Jack> Maybe I was not clear. I *know* that memory attribute aliasing
>   Jack> is a bad thing to do. I was commenting on Robin's mail and
>   Jack> providing a real-life example on where/how it causes
>   Jack> problems. Prefetching is a perfectly valid thing for the cpu
>   Jack> to do. Any time there is a valid TLB entry, prefetching can &
>   Jack> will happen. DONT allow a TLB entry to cover both cached &
>   Jack> uncached pages.
>
> Sounds like we're in violent agreement! ;-)
>
>         --david

I guess the question wasn't so much about attribute aliasing but
killing all intransit memory accesses and prefetch before its
safe to change the TLB attribute to uncacheble, with assurance that
all new mem refs/prefetch will come from memory. I appreciate
all your inputs.

- Mario.

