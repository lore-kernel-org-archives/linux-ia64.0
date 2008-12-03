From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Date: Wed, 03 Dec 2008 16:43:20 +0000
Subject: sshd segmentation fault on ia64 on 28-rc7-mmotm-081203
Message-Id: <1228322600.6693.61.camel@lts-notebook>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-netdev@vger.kernel.org, linux-ia64 <linux-ia64@vger.kernel.org>

I couldn't find anything on the list about this.

I've built and booted 28-rc7-mmotm-081203 on both x86_64 and ia64.  I
can ssh into the x86_64 platform fine.  On the ia64, I'm seeing sshd
[from RHEL5 distro] seg faulting.  [Same sshd worked on the
28-rc6-mmotm-081201 kernel.]

Has anyone else seen this?

Lee

