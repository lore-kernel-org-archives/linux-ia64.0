From: Don Dugger <n0ano@valinux.com>
Date: Tue, 22 Feb 2000 23:01:41 +0000
Subject: Re: [Linux-ia64] ILP32 support?
Message-Id: <marc-linux-ia64-105590678204958@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204954@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204954@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Also, there would have to be some changes to the kernel.  This would
create ELF64 processes that have to live within the first 4G of
memory.  We already support 32-bit processes but some kernel changes
would be required to identify this new entity.

On Tue, Feb 22, 2000 at 03:08:54PM -0800, David Mosberger wrote:
> >>>>> On Tue, 22 Feb 2000 14:21:14 -0800, "Vadim Furman" <vadimf@mainsoft.com> said:
> 
>   Vadim> Are there any plans to support ILP32 mode?  Vadim Furman
> 
> No.  So far, nobody has felt that the (small) benefits of ILP32 are
> worth its trouble.  No kernel mods would be required, but you'd have
> to create a completely new user-level environment (new compiler, new
> header files, all libraries would have to be recompiled with ILP32
> mode, etc.).
> 
> 	--david
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838


