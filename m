From: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>
Date: Fri, 21 Jun 2002 14:21:35 +0000
Subject: [Linux-ia64] /usr/lib/gcrt1.o on RH 7.2
Message-Id: <marc-linux-ia64-105590701905700@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 Dear all,

 Recently, I have been using RH 7.2 on ia64.
 Then I noticed that /usr/lib/gcrt1.o is wrong because
 I could not get result of gpof correctly. 
 When some of programs are compild with -p
 switch and run them. After that, I wanted to confirm
 the infomation by profiler using gprof command, but
 gprof could not run correctly, it gives me wrong
 result or nothing display or illegal instrcution.

 Does anyone already have any patches or any good idea?

-- 
End of my email
--
Yours faithfully,
Hideki Yamamoto   (V).v.(V) # Empowered by Innovation

