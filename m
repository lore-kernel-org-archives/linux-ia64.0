From: "Ahna, Christopher J" <christopher.j.ahna@intel.com>
Date: Tue, 09 Jan 2001 20:32:48 +0000
Subject: RE: [Linux-ia64] IA-64 Linux TODO list
Message-Id: <marc-linux-ia64-105590678205899@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205896@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've been looking at AGPGART and DRI for the Rage128 and the Matrox G400 for
a couple of months.  

I have an experimental version of a 460GX AGPGART driver which satisfies the
DRI modules in X to a great enough extent that I can boot into X and have
glxinfo report that direct rendering is enabled. The GART translation tables
look OK and GART translation seems to be occurring, however GL rendering
isn't working yet (typical failures involve a DRM module querying the
graphics adapter and not getting an adequate response).

If AGPGART for 460GX and a DRI module for Rage128 are going to be on the
TODO list, I'll sign up as the owner.  Thanks,

Chris

-----Original Message-----
From: Uros Prestor [mailto:uros@turbolinux.com]
Sent: Tuesday, January 09, 2001 12:06 PM
To: davidm@hpl.hp.com
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] IA-64 Linux TODO list


David Mosberger wrote:

>  - verify that all on-board hardware is supported and working:
>         - does cs4281 sound driver work reliably now?

Yes, we use it as a module and it works w/o problems.  You need an updated
mpg123 and/or xmms RPM, though.

> If you can think of anything else, please let me know---I'll try keep
> the list uptodate for now.

What's the status of kernel AGP support?  Also, the DRI module for ATI
Rage128
would be nice.

Uros

--
Uros Prestor
uros@turbolinux.com




_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


