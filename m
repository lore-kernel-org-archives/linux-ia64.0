From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 05 Aug 2002 20:31:00 +0000
Subject: RE: [Linux-ia64] mmap and malloc questions on IA-64 linux
Message-Id: <marc-linux-ia64-105590701905909@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905877@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905877@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 5 Aug 2002 08:40:17 -0700 , "Olivier, JeffreyX" <jeffreyx.olivier@intel.com> said:

  Jeff> Your suggestion that munmap() might fragment the map reminded
  Jeff> me of something else.  Upon receiving a write notice from
  Jeff> another node for a page, our system uses mprotect on the page
  Jeff> so that we can't write to it without causing a segmentation
  Jeff> fault.  Since we do this on a per-page basis, this is likely
  Jeff> the cause of the multiple mappings and since we are doing this
  Jeff> over such a large address space, it is likely that the linux
  Jeff> default of 65536 memory maps is the problem.  Does that seem
  Jeff> reasonable?

Yes, indeed.

  Jeff> I can see two possible solutions:

  Jeff> 1.  Develop an algorithm to efficiently combine memory
  Jeff> mappings with the same protections.  This would be fairly
  Jeff> straight forward for my program but for more sporadic memory
  Jeff> accesses, it might not work very well.

That's what the Linux kernel did up to the pre-2.4.0 series of
patches.  Then Linus ripped the merging logic out and replaced it with
something simpler.  The old merging logic had some nasty SMP issues,
IIRC.

It's something that should be discussed on the general linux-kernel
mailing list (linux-kernel@vger.kernel.org), as this is not specific
to ia64.

  Jeff> 2.  Change the default maximum number of mappings.  I noticed
  Jeff> a /proc/sys/vm/max_map_count variable.  Can this be increased
  Jeff> safely?

In the standard 2.4.18 kernel, MAX_MAP_COUNT is a hardcoded constant.
But in either case, AFAIK, the main reason for the existence of the
limit is to have (some) protection against denial-of-service attacks,
where a single process would consume huge amounts of kernel memory.
There is no a-prio limit in the kernel which would prevent you from
making the number as large as you want (well, within reason: map_count
is a signed 32-bit variable...).

	--david

