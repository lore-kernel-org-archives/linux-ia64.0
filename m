From: Sane_Purushottam@emc.com
Date: Wed, 25 Sep 2002 21:25:35 +0000
Subject: RE: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906067@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SG_IO. The application is sending SCSI commands to the devices.

Nitin Sane
sane_purushottam@emc.com
(508) 382-7319


-----Original Message-----
From: Don Dugger [mailto:n0ano@n0ano.com]
Sent: Wednesday, September 25, 2002 5:08 PM
To: Sane_Purushottam@emc.com
Cc: kevin.vanmaren@unisys.com; linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] platform detection at run-time


Nitin-

Can you tell me exactly which ioctl calls you're using that aren't
working?  We have code in the kernel to deal with just this situation.
I didn't transform EVERY ioctl in existence so let me know which ones
you're using and I'll fix them.

On Wed, Sep 25, 2002 at 03:33:12PM -0400, Sane_Purushottam@emc.com wrote:
> The reason, I have to detect the architecture at run time has to do with
the
> interface with (sg) driver. Since the driver is natively compiled for
> 64-bit, it expects the data structure handed over to it, to be 64-bit
wide.
> Thus my 32-bit application cannot issue ioctl calls successfully.
> 
> So, in my application, based on the platform, I fill the appropriate
> structure before ioctl call.
> 
> Nitin Sane
> sane_purushottam@emc.com
> (508) 382-7319
> 
> 
> -----Original Message-----
> From: Van Maren, Kevin [mailto:kevin.vanmaren@unisys.com]
> Sent: Wednesday, September 25, 2002 3:28 PM
> To: 'Sane_Purushottam@emc.com '; 'linux-ia64@linuxia64.org '
> Subject: RE: [Linux-ia64] platform detection at run-time
> 
> 
> Nitin,
> 
> Have you decided what you want to do about AMD's x86-64?
> That is another 64-bit platform that will run your 32-bit binary.
> 
> Ideally all three platforms would be enough alike you don't
> have to worry about it: is there a problem with Linux that is
> causing you to perform this check?
> 
> Kevin
> 
> -----Original Message-----
> From: Sane_Purushottam@emc.com
> To: linux-ia64@linuxia64.org
> Cc: Sane_Purushottam@emc.com
> Sent: 9/25/02 2:18 PM
> Subject: [Linux-ia64] platform detection at run-time
> 
> I have a linux application running on 32-bit machines. Due to some
> third-party limitations, we cannot build this application on 64-bit
> machines
> natively. Thus we'll be using the '32-bit compatibility mode'.
> 
> For some application specific reasons, I need to be able to determine at
> run-time whether the application is running on a 32-bit or a 64-bit
> platform.
> 
> What I have found is that there's no reliable way for the application to
> determine whether it's running on a 64-bit machine. I use info obtained
> from
> /proc/cpuinfo (more specifically family field) to determine the
> platform.
> However this is not standard. On Redhat 7.1 (lk 2.4.3-12) family value
> is
> set to IA-64 while on Redhat 7.2 (lk 2.4.9-34) this field is set to
> 'Itanium'.
> 
> What is the preferred method to determine the platform at run time ??
> Are
> these values likely to change (after I change my code to handle this)
> ????
> 
> Nitin Sane
> sane_purushottam@emc.com
> (508) 382-7319
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com

