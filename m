From: Neil Brown <neilb@cse.unsw.edu.au>
Date: Fri, 17 Oct 2003 00:47:14 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106635195709322@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday October 17, nathans@sgi.com wrote:
> > 
> 
> What's your preference here Neil?  I'll make a patch to create
> __kernel_old_ino_t for each arch and nfsd/syscall.h if you like
> that approach, else these patches seem to be all we need for ABI
> compatibility now.
> 
> thanks.

I don't really want __kernel_old_ino_t as it would clutter every arch
just for nfsd, and just for 2.6.

I think I would like

#ifdef __ia64__
 typedef unsigned int __nfsd_ino_t;
#else
 typedef __kernel_ino_t __nfsd_ino_t;
#endif

at the top of syscall.h, and then use __nfsd_ino_t where needed.
This would keep all the 'clutter' inside nfsd, and in one place, and I
can remove it all when I discard that system call in 2.7.

If other arch's want to change their __kernel_ino_t, then we just need
to add a make a change within that #if/#endif

NeilBrown
