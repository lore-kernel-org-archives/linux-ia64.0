From: Jack Steiner <steiner@sgi.com>
Date: Sat, 10 May 2003 02:39:54 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705717@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> >>>>> On Fri, 9 May 2003 15:02:47 -0500 (CDT), Jack Steiner <steiner@sgi.com> said:
> 
>   >> Would there be a downside to this on SGI's machines?
> 
>   Jack> I dont see any significant problems. It actually seems easy.
> 
> Good.
> 
>   Jack> I think we still need to use __tpa() for addresses assigned by
>   Jack> the loader.  The standard __pa() macros wont work in region 5.
> 
> That's why I don't mind: nobody can use __pa() on region 5 anyhow, so
> using something different (page table walk or __tpa()) is OK.  I was
> real uneasy with having a "magic" address range inside region 7, where
> __pa() wouldn't work.  But in region 5, no problem.
> 
> It might be good to call __tpa() something different: it's too close
> to __pa() and the difference may easily be overlooked.  For example,
> ia64_tpa() would make it obvious that we're talking about an ia64
> instruction.

Seems reasonable.....


> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


