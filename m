From: "Pat O'Rourke" <orourke@mclinux.com>
Date: Tue, 17 Oct 2000 16:44:54 +0000
Subject: [Linux-ia64] uni-processor kernel on SMP machine
Message-Id: <marc-linux-ia64-105590678205576@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I attempted to boot a 2.4.0-test9 kernel compiled without SMP support
on an MP Lion, but it would not boot.  I did the same experiemnt with
older kernels and it appears this broke between test7 and test8.  Has
anyone else noticed this?  Is there a work around / solution?

I noticed the problem on both a 2-way lion w/ B1 cpus and a 4-way lion
with A2 cpus.

Thanks,

Pat

-- 
Patrick O'Rourke
orourke@missioncriticallinux.com



