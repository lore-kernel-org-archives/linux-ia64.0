From: "Ahna, Christopher J" <christopher.j.ahna@intel.com>
Date: Wed, 18 Oct 2000 19:30:07 +0000
Subject: RE: [Linux-ia64] uni-processor kernel on SMP machine
Message-Id: <marc-linux-ia64-105590678205593@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205576@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205576@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Are you using a kernel with ptc.g enabled?  A problem similar to the one you
are seeing has shown up B1-based systems running kernels that include ptc.g.
Thanks,

Chris

-----Original Message-----
From: Pat O'Rourke [mailto:orourke@mclinux.com]
Sent: Wednesday, October 18, 2000 6:23 AM
To: Jun Nakajima
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] uni-processor kernel on SMP machine 


> Both UP and SMP kernels (2.4.0-test9) work fine on at least two 4-way
> Lions (A2-stepping CPUs each with latest and a bit old firmware) at our
> site. Can you be more specific about the problem you are seeing?

The system appears to hang right after printing "POSIX conformance testing
by UNIFIX", i.e. just before the creation of the init thread.  The kernel
is pretty locked up, alt-sysrq doesn't work.  I have not really tried to
debug it yet, so that is about all I can say at the moment.

Pat

-- 
Patrick O'Rourke
orourke@missioncriticallinux.com



_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

