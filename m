From: Khalid Aziz <khalid.aziz@hp.com>
Date: Thu, 18 Nov 2004 15:34:41 +0000
Subject: Re: [Fastboot] [PATCH] Fix for kexec reboot failing after multiple
Message-Id: <1100789511.1992.8.camel@minuet.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <419BD2AB.1050203@osdl.org>
In-Reply-To: <419BD2AB.1050203@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Randy,

I do not understand how kernel parameters are passed on other
architectures. So I had not attempted to look if this problem plagues
other architectures as well. Now in my case, this problem showed up
because I have not implemented kernel parameter passing yet. I am simply
copying parameters for running kernel into param area for the kexec'd
kernel and appending "kexec_reboot" to the parameters since I need to
know whether the kernel booting up is cold booted or kexec booted so I
can virtualize EFI or not. So I exepcted this problem to be unique to
ia64 code.

I will take a look at other architectures as well.

--
Khalid

On Wed, 2004-11-17 at 15:37, Randy.Dunlap wrote:
> Khalid Aziz wrote:
> > kexec patch I had sent out earlier has bug where it appends
> > "kexec_reboot" to kernel parameters blindly. After several kexec reboots
> > from kexec'd kernel, kernel parameters line becomes too long and kernel
> > fails to boot. Attached patch  will cure this. Patch
> 
> This particular problem is not ia64-specific.  I have seen it on ia32.
> Did you fix it in a generic manner (for any $arch) ?
> 
> > kexec-ia64-reboot.diff can be applied on top of the previous patch I had
> > sent. Patch 2.6.8.1-kexec3-ia64-2.diff includes this fix and is
> > repalcement for my previous patch. 
> > 
> > My current kexec patches for ia64 can also be found at
> > <http://free.linux.hp.com/~khalid/kexec-ia64/>.
> 
> Thanks,
-- 
Khalid Aziz                                 Linux and Open Source Lab
(970)898-9214                                         Hewlett-Packard
khalid_aziz@hp.com                                   Fort Collins, CO

