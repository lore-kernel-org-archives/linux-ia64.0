From: "Kaigai Kohei" <kaigai@ak.jp.nec.com>
Date: Fri, 11 Jun 2004 01:13:38 +0000
Subject: Re: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <004d01c44f51$543a2ae0$f97d220a@linux.bs1.fc.nec.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <Xine.LNX.4.44.0406101657420.8385-100000@thoron.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, selinux@tycho.nsa.gov
Cc: James Morris <jmorris@redhat.com>

James Morris wrote:
> Were you using a standard kernel, or was this a vendor or otherwise 
> patched kernel?  I know people have booted IA64 with SELinux enabled in 
> recent times with no problems.

Yes, I booted up both of the standard kernel (2.6.6) with both of the previous patches.
SELinux was configured to the Permissive-mode.
(I have not tried to boot up with the Enforcing-mode.)

I'm interested in the case you mentioned.
In my experience, kernel panic always occurs while booting up.
What is written in /etc/sysconfig/selinux?
--------
Kaigai Kohei, Linux Promotion Center, NEC
E-mail: kaigai@ak.jp.nec.com
