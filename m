From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Tue, 18 Apr 2000 23:17:28 +0000
Subject: RE: [Linux-ia64] Kernel long branch support
Message-Id: <marc-linux-ia64-105590678205020@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205018@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205018@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We are working on the code to emulate "branch long" instruction and will
have the code soon.

Thanks,
Asit


-----Original Message-----
From: David Mosberger [mailto:davidm@hpl.hp.com]
Sent: Tuesday, April 18, 2000 4:13 PM
To: roneng@ca.ibm.com
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Kernel long branch support


>>>>> On Tue, 18 Apr 2000 18:47:38 -0400, roneng@ca.ibm.com said:

  Ronen> Hi, I am getting an illegal instruction fault from the kernel
  Ronen> after using the latest linker which supports long branches
  Ronen> (i.e. branches greater then 16M) to compile large shared
  Ronen> libraries.  I was wondering if anyone knows if the latest
  Ronen> kernels 2.3.51/or 2.3.50 support long branches, or if anyone
  Ronen> is working on long branch support for the kernel.

The kernel support for "branch long" emulation doesn't exist yet.
Patch welcome. ;-)

	--david


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64



