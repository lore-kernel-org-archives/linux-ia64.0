From: Don Dugger <n0ano@n0ano.com>
Date: Tue, 05 Mar 2002 17:46:29 +0000
Subject: Re: [Linux-ia64] Fix for for memory leak in IA32 mmap
Message-Id: <marc-linux-ia64-105590701905225@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905222@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905222@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David-

Yep, it was a virtual memory leak.  Intel came up with a Fortran
program that was allocating and freeing lots of anonymous `mmap's.
It was really nasty because it wasn't even the same request all the
time, it had something like 3 different odd size requests that it was
`mmap'ing and `munmap'ing, all in a loop and eventually it ran out
of VM.

I like the idea of keeping a bitmap.  I still have to keep a list,
it'll actually be a bigger list since I'll have to keep track of
fixed requests also, but that should handle ALL cases (even the case
where a program makes an odd sized non-fixed `mmap' followed by a
fixed `mmap' into the middle of the last page).  Give me a few days
and I'll see if I can't come up with something.

On Tue, Mar 05, 2002 at 09:34:37AM -0800, David Mosberger wrote:
> >>>>> On Tue, 5 Mar 2002 08:13:01 -0700, Don Dugger <n0ano@n0ano.com> said:
> 
>   Don> David- Here is a patch against `linux-2.4.17-ia64-011226.diff'
>   Don> that fixes a memory leak with the IA32 `mmap'/`munmap' calls.
>   Don> The problem occurs when a non-fixed `mmap' allocates a range
>   Don> that ends in the middle of a page.
> 
> Nasty.  You're talking about a _virtual_ address space leak, right?  Do
> you know the exact sequence of events that causes application failure?
> 
>   Don> To handle problems with
>   Don> fixed requests the `munmap' call rounds down the the area
>   Don> freed, causing the memory leak.  The only solution I can think
>   Don> of to deal with this is to create a list of the allocated
>   Don> starting addresses for all non-fixed `mmap' requests.  `munmap'
>   Don> then checks this list and, if it finds a match, rounds the
>   Don> request size up rather than down.
> 
> It seems to me what we really want to do is keep track of partially
> mapped pages.  I think we'd need a bitmask showing which ia32 pages
> have been mapped in an ia64 page.  Say, a 16KB page whose first 4KB
> have been mapped would be represented as:
> 
> 	       ia32 page:
> 	0	1	2	3
> 
> 	1	0	0	0
> 
> now, if someone maps the 3rd 4KB page, you'd get:
> 
> 	       ia32 page:
> 	0	1	2	3
> 
> 	1	0	1	0
> 
> and so on.  The underlying ia64 page would then have to be freed
> whenever the bitmask becomes empty.
> 
> 	--david

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com
Ph: 303/449-0877

