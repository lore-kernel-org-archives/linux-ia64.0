From: david mosberger <dmosberger@gmail.com>
Date: Tue, 26 Jul 2005 05:20:21 +0000
Subject: fix possible mm_context wrap-around race
Message-Id: <ed5aea430507252220db22b1c@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony, since I can't test the patch on anything but a UP machine at
this time (which is uninteresting, since the race doesn't trigger
there), I'd suggest to put this into the "testing" tree.  Hopefully,
somebody could run some tests which involve multi-threaded apps doing
a lot of fork/exec'ing.

Thanks,

  --david
-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
