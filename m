From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Sun, 27 Oct 2002 16:14:48 +0000
Subject: RE: [Linux-ia64] Is there any good linux/ia64 kernel debugger?
Message-Id: <marc-linux-ia64-105590709805261@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805259@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805259@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Have you tried kgdb?  http://oss.sgi.com/projects/kgdb
I've used kdb, which works well with a serial console
(but not with a USB keyboard).

Kevin


-----Original Message-----
From: Jassie Tsai
To: linux-ia64@linuxia64.org
Sent: 10/27/02 10:21 AM
Subject: [Linux-ia64] Is there any good linux/ia64 kernel debugger?

I am tracing and modifying linux kernel-2.4.14-ia64.
Is there any good kernel source debugger to use?
Thanks very much!!!

Jassie Tsai


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

