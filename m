From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Dec 2004 23:08:35 +0000
Subject: Re: [patch 2.6.10-rc3] Add TIF_SIGDELAYED processing
Message-Id: <16824.56051.207249.1262@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <15449.1102482344@kao1.melbourne.sgi.com>
In-Reply-To: <15449.1102482344@kao1.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 09 Dec 2004 12:41:33 +1100, Keith Owens <kaos@sgi.com> said:

  >>  It seems rather dangerous to stash away PIDs and deliver signals
  >> to them later on.  It's just an invitation for races, IMHO.

  Keith> The pid is checked to see if it is still valid, see
  Keith> do_sigdelayed().  Yes, there is a very small race where the
  Keith> pid could be reused, but to hit that race we have to -

I just think stashing away pids in the kernel is a slippery slope we
do not want to get onto.

Can't you stash away a reference to the task-structure and bump the
reference count?  I suspect that might get you into trouble when a
task exits with first unmapping all MMIO-memory, but that's might not
be so hard to deal with (when task exits, check whether it has any
MMIO mappings and if so, kill those, or at least the associated
registrations first).

	--david
