From: "Donny Cooper" <dcooper@hstc.necsyl.com>
Date: Thu, 26 Apr 2001 16:41:37 +0000
Subject: RE: [Linux-ia64] Re: malloc problems
Message-Id: <marc-linux-ia64-105590693005475@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005474@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005474@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bill,

This code is a small subset of a very large application, that runs on many
platforms, an is being ported and tuned for IA64 Linux.
The executable builds and runs fine, but always grabs a different memory
area on the one BigSur, as opposed to the others.

Thanks.

Donny

-----Original Message-----
From: linux-ia64-admin@linuxia64.org
[mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Bill Nottingham
Sent: Thursday, April 26, 2001 10:03 AM
To: !IA64-Dist-Linuxia64 (E-mail)
Subject: [Linux-ia64] Re: malloc problems


Donny Cooper (dcooper@hstc.necsyl.com) said:
> dynamic_area = (unsigned char *) malloc ( membytes );
> printf(" dyn_area = %x %lx, mem= %x
\n",dynamic_area,dynamic_area,membytes);
>
> Result from Tom: (1-way BigSur)
> dyn_area = 40000010 40000010, mem= 2000018

It looks like you forgot a prototype for malloc.

Bill

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


