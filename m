From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Tue, 03 May 2005 22:29:51 +0000
Subject: Kernel autobuild now uses Git
Message-Id: <20050503222951.GE26031@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, Ia64 Linux <linux-ia64@vger.kernel.org>
Cc: Git Mailing List <git@vger.kernel.org>

Hi All
  Our ia64 autobuild system has been moved from using
BK to Git. Here we do a nightly pull on Linus's 
(not so mainline) Git tree and test the ia64 build.

This may be a benefit to the Git developers to see
the results of a nightly 'cg-pull'.

Thanks to all for the effort, the conversation from BK
to Git was relatively painless.

 - dsw

--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
