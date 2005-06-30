From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 30 Jun 2005 10:13:03 +0000
Subject: RE: problem booting -mm2 kernel on rx2600
Message-Id: <1120126383.12930.5.camel@uluru.grenoble.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506291236.14024.bjorn.helgaas@hp.com>
In-Reply-To: <200506291236.14024.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Matt Chapman found a work around for my problem with
booting 2.6.12-mm2 on my rx2600. Basically it can boot in
SMP mode, if we bypass some of the migration cost
measurements using the command line option migration_cost
Given that the same kernel boots on some other rx2600, it
seems like there may be a timing bug/race in this code.
Could your GIT bisect method identify a change in that 
piece of code?


