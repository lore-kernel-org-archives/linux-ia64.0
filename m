From: Jack Steiner <steiner@sgi.com>
Date: Thu, 03 Feb 2005 02:25:14 +0000
Subject: Re: Abusing region 0
Message-Id: <20050203022514.GA5337@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42017845.9080507@free.fr>
In-Reply-To: <42017845.9080507@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 03, 2005 at 02:03:01AM +0100, Menyhart, Zoltan wrote:
> I am going to do some experiments: I am going to map some of the
> virtual address ranges of a process into the address space of another
> one. They are real 64 bit processes, i.e. the region 0 is not used.
> Can I abuse this region 0 for mapping the addresses of the neighbor
> process into this region ? E.g. if process A has got an address at
> 0x6000000000001000, then I am going to map it for B at address
> 0x0000000000001000 ? Wont anything break ?
> 
> (I need this trick because the source address can correspond to
> anything, like initialized data, BSS, anonymous allocation, etc, i.e.
> some SHM just wont work.)
> 
> Any advice will be appreciated.

FWIW, I have done the same thing that you are trying except that I used
address 0x0000000010000000 instead of 0x0000000000001000. No problems.


> 
> Zoltan Menyhart
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


