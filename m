From: Don Dugger <n0ano@valinux.com>
Date: Fri, 10 Mar 2000 17:31:18 +0000
Subject: Re: [Linux-ia64] crosscompiler ?
Message-Id: <marc-linux-ia64-105590678204978@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thomas-

I'm not totally sure what you're asking for but if you want to create
IA32 binaries on an IA64 system there is a fairly simple solution that
should work.  You can install an IA32 `gcc' compiler on your IA64 machine
and it should just work.  It it doesn't then there is a bug in the IA32
support that I need to know about and fix.

I haven't done this yet because I'm tracking down other problems but
I actually plan to try this out when I get a chance.

On Fri, Mar 10, 2000 at 07:06:33PM +0100, Thomas Hiller wrote:
> Is a crosscompiler for linuix-ia32 available somewhere or is it really
> necessary to build it by myself ?
> Are there any problems why there is no binary distribution yet ?
> 
> Thanks in advance.
> 
> Regards,
> Thomas
> 
> --
> Thomas Hiller                                           thomas.hiller@compaq.com
> COMPAQ Computer Corporation                             thomas.hiller@sap.com
> Global SAP Solution Center                              Tel: +49 6227 / 7-45426
> LinuxLab @ SAP, Walldorf                                Fax: +49 6227 / 7-43027
> 
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


