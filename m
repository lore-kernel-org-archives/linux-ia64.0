From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 27 Nov 2001 20:38:31 +0000
Subject: [Linux-ia64] what's up with 2.5?
Message-Id: <marc-linux-ia64-105590698805551@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, various people are justly wondering how 2.4 and 2.5 are going to
be maintained etc.  Here are some of my thoughts.  I'd appreciate your
thoughts:

 - For the time being, I'm willing to maintain both 2.4 and 2.5.  This
   assumes that 2.4 will rev infrequently.  If 2.4 revs too
   frequently, I'd appreciate help.

 - The big issue on my mind is how we're going to handle McKinley.
   Even if Linus planned to do so, it's extremely unlikely that 2.6
   will happen before McKinley is out.  I believe there are really two
   separate issues here: McKinley support per se and NUMA support.
   From what I can tell, we should be able to support McKinley in 2.4
   *without* NUMA quite easily.  My sense is that the NUMA related
   changes will be quite broad.  Thus, I suggest that we initially
   focus on 2.5 for this.  As McKinley gets closer, perhaps some of
   the NUMA-motivated changes can be back ported to 2.4.

 - My first priority is to get the remaining platform-independent
   differences integrated into the official Linus tree.  The obvious
   goal being that it should (finally) become possible to build an
   ia64 kernel out of the box.

 - There are many things that can be improved in ia64 linux.  I
   believe the optimizing the system call path, experimenting with
   superpage (and perhaps subpage) mappings, and experimenting with
   better TLB sharing are all fruitful directions to consider.  I have
   a pretty good idea of what can and should be done with the syscall
   path and am planning to work on that as soon as I can find some
   time.

Comments?

	--david

