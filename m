From: Jason P Holland <jholland@cs.selu.edu>
Date: Wed, 30 Oct 2002 16:30:17 +0000
Subject: RE: [Linux-ia64] PXE boot off HP zx6000
Message-Id: <marc-linux-ia64-105590709805296@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805294@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805294@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

i'm using RedHat Advanced Workstat 2.1aw, beta ;)  We will move to the 
release as soon as it comes out though.

jason

> Jason -
> 
> What are the details of the Red Hat version you are using?  RH 7.1 and 7.2
> do not work on zx6000, and RHAS 2.1 for Itanium (which will work on these
> boxes) has not yet been released.
> 
> Alan
> 
> > -----Original Message-----
> > From: Jason P Holland [mailto:jholland@cs.selu.edu]
> > Sent: Wednesday, October 30, 2002 9:19 AM
> > To: linux-ia64@linuxia64.org
> > Subject: [Linux-ia64] PXE boot off HP zx6000
> > 
> > 
> > 
> > hello,
> >   i'm trying to do a PXE boot from an HP zx6000 workstation.  My tftp 
> > server is version 0.29-3 for Redhat ia4.  I'm also using dhcp 
> > 3.0p11-9.  I 
> > get the following error from the EFI shell trying to do a lanboot
> > 
> > PXE-E05:  Download buffer is smaller than the requested file
> > Exit status code: Invalid Parameter
> > 
> > i've seen a few messages about this in the archives, but 
> > nothing i tried
> > has worked.  the file i want to boot off of is pxelinux.0 from the
> > syslinux package.  its only 10820 bytes, is the buffer really 
> > too small or
> > is there another problem i'm just not seeing?  if i need to post some
> > config files, please let me know.  thanks
> > 
> > jason
> > 
> > 
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> > 
> 


