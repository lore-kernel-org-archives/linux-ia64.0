From: Don Dugger <n0ano@valinux.com>
Date: Thu, 07 Jun 2001 20:02:08 +0000
Subject: Re: [Linux-ia64] Help with running IA32 apps on SuSE 7.1b Itanium
Message-Id: <marc-linux-ia64-105590693005698@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005697@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005697@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Uday-

Uh, we need a little more detail on what your problem is.  Exactly how
does your IA32 program fail?  My guess would be that you don't have
the necessary IA32 shared libraries installed on your machine.  Can
you run an IA32 version of `ldd' on your app. to see if all of its
libraries are available?

On Thu, Jun 07, 2001 at 12:03:12PM -0700, Ivaturi, Uday B wrote:
> 
>  Hi,
> 
>  I'm trying to run IA32 apps on SuSE 7.1 beta (2.4.2 kernel) BigSur-B3
> Itanium. It works on Turbo Linux Beta 3 Itanium, but I cant seem to run them
> on SuSE 7.1 beta. 
>    
>  Does anyone know if this version of SuSE has/doesnt have this feature ? Do
> I need to install any patches or change some configurations etc to make this
> work ? Any information is appreciated. Thanks in advance.
> 
> Uday Ivaturi
> Sofware Engineer
> MSL, Intel Corporation.
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

