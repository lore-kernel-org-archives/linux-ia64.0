From: n0ano@indstorage.com
Date: Fri, 18 Jan 2002 18:54:49 +0000
Subject: Re: [Linux-ia64] race conditions in ia32 subsystem
Message-Id: <marc-linux-ia64-105590698805881@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805879@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805879@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David-

I'm up for taking a stab at this.  It might be a week or so, I'm pretty
busy right now, but I'll get to it.

On Fri, Jan 18, 2002 at 10:14:08AM -0800, David Mosberger wrote:
> A while we discussed the race conditions that are present in the ia32
> subsystem when the page size is greater than 4KB.  It occurred to me
> that these problems can be fixed easily and cleanly by using the
> get_user_pages() routine (this routine was introduced in 2.4.17, if
> memory serves).
> 
> The basic idea would be to use the address space's mmap_sem instead of
> the global ia32_mmap_sem and to use get_user_pages() instead of
> copy_from_user()/copy_to_user() to access memory.
> 
> Does someone want to take a stab at doing this?
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

