From: Don Dugger <n0ano@valinux.com>
Date: Fri, 03 Nov 2000 15:36:28 +0000
Subject: Re: [Linux-ia64] NFS problems with 2.4.0-test10
Message-Id: <marc-linux-ia64-105590678205650@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205648@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205648@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Uros-

Are you running the EFI `wkaround' utility?  That will correct
some errata that might be affecting you.

On Thu, Nov 02, 2000 at 06:48:27PM -0800, Uros Prestor wrote:
> Has anybody observed NFS problems with the latest kernel?  I have
> installed 2.4.0-test10 + 1101 patch on a 4xB1 Lion; I can reliably crash
> a system by copying a large file over the NFS.  I have no problems with
> the same kernel on a 2xB2 BigSur.  Kernel was compiled with all the
> B-stepping workarounds enabled and none for the A-steppings.
> 
> Uros
> 
> --
> Uros Prestor
> uros@turbolinux.com
> 
> 
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

