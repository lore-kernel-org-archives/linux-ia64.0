From: "Broadfoot, KenX" <kenx.broadfoot@intel.com>
Date: Wed, 09 Aug 2000 16:37:30 +0000
Subject: RE: [Linux-ia64] Kernel: which machine to choose?
Message-Id: <marc-linux-ia64-105590678205292@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for that info...

I just strip the kernel....that seems to work as well..

--ken

> -----Original Message-----
> From:	Don Dugger [SMTP:n0ano@valinux.com]
> Sent:	Tuesday, August 08, 2000 12:15 PM
> To:	linux-ia64@linuxia64.org
> Subject:	Re: [Linux-ia64] Kernel: which machine to choose?
> 
> Gerrit-
> 
> By default the top level `Makefile' specifies the `-g' flag, which puts
> about 40MB of debug info into the kernel executable.  Just remove this
> flag
> and your kernel should drop dramatically in size.
> 
> On Tue, Aug 08, 2000 at 11:55:11AM -0700, Gerrit.Huizenga@us.ibm.com
> wrote:
> > 
> > $ gcc -v
> > Reading specs from
> /usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/specs
> >  gcc version 2.9-ia64-000216-final
> > 
> > I get 40 MB kernels, although the size of text/data/bss/etc. are about
> the
> > same as the 7-8 MB kernels shipped with the RedHat distro on my machine.
> 
> -- 
> Don Dugger
> "Censeo Toto nos in Kansa esse decisse." - D. Gale
> n0ano@valinux.com
> Ph: 303/938-9838
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


