From: n0ano@indstorage.com
Date: Tue, 05 Mar 2002 22:18:53 +0000
Subject: Re: [Linux-ia64] Fix for for memory leak in IA32 mmap
Message-Id: <marc-linux-ia64-105590701905231@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905222@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905222@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony-

I'll keep the idea of a 2-level bitmap in mind but I don't see a problem
with just a bitmap for partial pages.  With a 64-bit long for the bitmap
I can deal with page sizes up to 256K which should be sufficient.  Since
the page size is a compile time constant I just have to come up with
suitable define macros and it should be relatively easy to deal with the
bitmap.

On Tue, Mar 05, 2002 at 01:49:09PM -0800, Luck, Tony wrote:
> > 3)  I wasn't intending to keep a bitmap for all of IA32 addressable
> > memory.  I intend to keep a list of all the partial pages, basically
> > the first and last page of an `mmap' request, and then keep a bitmap
> > for each of the 4K chunks inside of that page.  Maintaining the bitmap
> > will be a little tricky to handle all of the `mmap/munmap' possibilities
> > but it shouldn't be all that hard to get it right.
> 
> Aha! A list of the partial pages makes sense. I thought that the "list" was
> going to be a list of mmap'd ranges ... which would be tougher to get right
> in the face of pathalogical programs.  I agree that these pathalogical
> programs deserve to fail, but they shouldn't take out the system (or tie it
> up with incredibly long lists of objects).
> 
> You might keep an eye on the complexity of the code for maintaining the
> lists
> versus just having a (2-level) bitmap for the whole of the IA-32 address
> space.  There are some tricky cases (especially when you factor in support
> for 64K kernel page size as well as 16K ... so your partial page bitmaps
> have different lengths for different configurations).
> 
> -Tony

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

