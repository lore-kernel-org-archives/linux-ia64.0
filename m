From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 01 Aug 2002 18:09:30 +0000
Subject: Re: [Linux-ia64] mmap and malloc questions on IA-64 linux
Message-Id: <marc-linux-ia64-105590701905878@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905877@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905877@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 1 Aug 2002 09:47:37 -0700, "Olivier, JeffreyX" <jeffreyx.olivier@intel.com> said:

  Olivier> For a shared heap size of 1.2 GB, the application runs but
  Olivier> it fails to complete.  One of the mallocs complains that it
  Olivier> the system is out of memory.

Find out why the malloc is complaining.  It could be that something
got mmap'ed relatively close to the break value.  If so, attempting a
(small) malloc might cause the break value to cross into the mmaped
area, which would cause it to fail.

To track this down, I'd recommend to look at:

	- /proc/PID/maps (where PID is the process ids of the "interesting"
	  tasks)
	- the output of free

Hope this helps,

	--david

