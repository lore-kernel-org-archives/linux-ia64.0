From: Chris McDermott <lcm@us.ibm.com>
Date: Tue, 23 Apr 2002 20:53:48 +0000
Subject: [Linux-ia64] running X with 2.4.18 kernel
Message-Id: <marc-linux-ia64-105590701905497@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Anybody running X with a 2.4.18 (either 0226 or 0410 ia64 patch) kernel? 
I discovered a couple of weeks ago that it didn't work, at least with 
the kernels I'm building. Now, I'm finally getting around to trying this 
again. The systems that fail are running RH 7.2 (with XFree86-4.1.0-8 
or XFree86-4.1.0-15). I have also built and installed XFree86 4.2.0, 
same results. I'm just now starting to debug this, but thought I'd take 
the lazy way out first and see if anybody else has seen/solved this. Here
is what I see in the log file:

(II) LoadModule: "scanpci"
(II) Loading /usr/X11R6/lib/modules/libscanpci.a
(II) Module scanpci: vendor="The XFree86 Project"
	compiled for 4.2.0, module version = 0.1.0
	ABI class: XFree86 Video Driver, version 0.5

Fatal server error:
Caught signal 11.  Server aborting


Thanks,

Chris


