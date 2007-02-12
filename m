From: "Karthik Gopalakrishnan" <karthik.g.krishnan@gmail.com>
Date: Mon, 12 Feb 2007 19:46:20 +0000
Subject: 2.6.19 - MCA in dmi_scan on an Orca
Message-Id: <5e0a1fd80702121134u47c08388s762bce2c712c0f8e@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Folks.

When I booted 2.6.19 on an IA Superdome (Orca), the kernel caused an
MCA around the "dmi_scan" function. When I set "CONFIG_DMI = n", it
was automatically set back to "y" during the build. I had to
workaround the problem by commenting out
"core_initcall(run_dmi_scan)". On doing so, the MCA went away.

So, my questions are:
1. Does the Orca actually have a DMI Interconnect, or is the Kernel
detecting it wrongly?
2. Is there a cleaner way to disable DMI in such situations?

I am sorry if these questions were answered on another list. I will be
grateful if someone can point me to those posts.

Thanks & Regards,
Karthik
