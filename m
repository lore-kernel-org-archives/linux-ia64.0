From: Vadim Furman <vadimf@mainsoft.com>
Date: Tue, 29 Aug 2000 00:36:58 +0000
Subject: RE: [Linux-ia64] Re: [Ia64] Netscape (32-bit) locks machine
Message-Id: <marc-linux-ia64-105590678205397@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205388@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205388@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is it a patch to the kernel? If so, which kernel version it will be/is
incorporated into? 

-----Original Message-----
From: Michael Madore [mailto:mmadore@turbolinux.com]
Sent: Monday, August 28, 2000 9:47 AM
To: Don Dugger
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Re: [Ia64] Netscape (32-bit) locks machine


> Mike-
> 
> I must have been asleep since I don't remember seeing the original
message.
> 
> If your machine is crashing when running Netscape I would be suspicious of
> Netscape before I'd blame the X server.  I just discovered a few weeks
> ago that you have to put the system in `trickle' mode if you want to run
> IA32 programs, including Netscape, reliably.  I understand you can set
> `trickle' mode on the Lion BIOS.  For BigSur's there's a patch for the
> kernel you can get from Intel to do this (I can't send you the patch, you
> need to send a message to `Asit.K.Mallick@intel.com' if you want it).
> 

No, you weren't asleep.  The original message only went to the XFree list,
but I wanted to broaden the audience a little bit.

The problem is not restricted to netscape (at least on lions), but it
certainly seems to cause the lockup most frequently.  I beleive Uros has
the patch you are speaking of.  Thanks.

Mike Madore
Software Engineer
TurboLinux, Inc.


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

