From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Jan 2005 19:19:35 +0000
Subject: Re: glibc-2.3.2 NPTL caveat
Message-Id: <16885.19015.970909.435210@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16879.19106.549352.469688@napali.hpl.hp.com>
In-Reply-To: <16879.19106.549352.469688@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Jan 2005 11:34:26 +0000, Tim Cutts <tjrc@sanger.ac.uk> said:

  Tim> That explains a lot of problems we had with MySQL crashing
  Tim> almost instantly on startup on IA64 machines too.  So what
  Tim> needs to be done?  Is it as simple a fix as always compiling
  Tim> ld-linux with the larger of the two thread struct sizes? (he
  Tim> says, extremely naively, since this is the sort of thing in
  Tim> Linux that he has no clue about whatsoever - it comes under the
  Tim> heading of "scary stuff you leave to Really Clever People to
  Tim> think about" :-)

I _think_ the correct fix is to ask the thread-library what the
correct offset/size is, but I'm unsure if the infrastructure needed to
do so is already there.

	--david
