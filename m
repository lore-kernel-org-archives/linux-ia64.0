From: Gerrit.Huizenga@us.ibm.com
Date: Tue, 08 Aug 2000 18:55:11 +0000
Subject: Re: [Linux-ia64] Kernel: which machine to choose?
Message-Id: <marc-linux-ia64-105590678205279@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I noted recently that I couldn't build a kernel on the Lion when
rlogin'd to the machine, but at the console I seem to have no
problem.

Could the problems be a deadlock or other problem in the test1/test4
linux tcp code?

I've also noted that when compiling kernels with:

$ gcc -v
Reading specs from /usr/lib/gcc-lib/ia64-redhat-linux/2.9-ia64-000216-final/specs
 gcc version 2.9-ia64-000216-final

I get 40 MB kernels, although the size of text/data/bss/etc. are about the
same as the 7-8 MB kernels shipped with the RedHat distro on my machine.
And, trying to get the newer compiler to work on the RedHat distro has
been a little problematic.  I'm trying to bootstrap my way to a newer
kernel on the Lion (newer that ~test1) and running into problems where
the Dig kernel won't boot.

Procs are all A3 in the Lions.

gerrit

> David Mosberger wrote:
> 
> > I wouldn't recommendn turning on AzusA hacks unless you have an AzusA
> > machine.
> 
> Why is that?  Our kernels have been compiled with AzusA hacks enabled and we had no problems
> with our kernels running on BigSurs and Lions.
> 
> On another note, we are getting a lot more segfaults during builds lately.  The 0505 release
> which had the 2.3.99-pre6 kernel was rock solid; after moving to 2.4.0 kernels the segfaults
> came back with a vengeance.  We did upgrade processors from A2 to A3 but I don't think this
> could be a culprit.  Any ideas on this?
> 
> Thanks,
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
> 

