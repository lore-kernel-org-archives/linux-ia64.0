From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Mon, 11 Jun 2001 23:03:57 +0000
Subject: RE: [Linux-ia64] Max size of shared memory segment.
Message-Id: <marc-linux-ia64-105590693005713@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005710@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005710@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Normally this is set to 32MB, but you can change it in file
include/linux/shm.h (parameter SHMMAX).  There is also /proc interface for
shared memory parameters, but I don't think that  you can use this interface
to modify the parameters.....

rohit

-----Original Message-----
From: Michael Madore [mailto:mmadore@turbolinux.com]
Sent: Monday, June 11, 2001 2:32 PM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] Max size of shared memory segment.


Hi,

What is the maximum size a shared memory segment can have on linux IA64?

-- 
Mike Madore
Senior Software Engineer
TurboLinux, Inc.
(650)228-5203

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


