From: "Olivier, JeffreyX" <jeffreyx.olivier@intel.com>
Date: Thu, 01 Aug 2002 16:47:37 +0000
Subject: [Linux-ia64] mmap and malloc questions on IA-64 linux
Message-Id: <marc-linux-ia64-105590701905877@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am trying to enhance a large distributed virtual shared memory system by
relaxing the constraints on the size of the shared heap.  I am doing
experiments running an openMP application that allocates a large shared heap
and writes to every location and reads the value of every location on the
other machine.  I realize that this is extremely inefficient but it is meant
to test the robustness and functionality of this large shared heap.

Currently, the shared heap is allocated via the following mmap call

mmap(addr, len, prot, flags, fd, 0)

where 
addr = 0
len = size of heap
prot = PROT_READ|PROT_WRITE
flags = MAP_SHARED|MAP_FILE
fd is a pointer to a file called /scratch1/heap.<pid>

This file is created, opened, the last byte is written to, and then it is
unlinked before performing the mmap.

Also, our system is based on Lazy Release Consistency so for each page there
is a twin and the behavior of our application forces us to need enough
physical space to hold the twins so I also created a twin mapping following
the same procedure as before.

These mappings succeed and the program starts to run.

I also created wrappers in my application for malloc, free, realloc, and
calloc to monitor how much memory is requested by the program.

The machines I am running on are identical Itaniums running redhat linux.
Both machines have 1.0 GB RAM and 1.5 GB of swap space.  The /scratch1
partition is 18 GB and was added solely for testing this application.

For a shared heap size of 1.0 GB, the application runs correctly.  The total
mmap for this app is 2.0 GB (shared heap and twins) and memory allocated
through the malloc family is about 300  MB.

For a shared heap size of 1.2 GB, the application runs but it fails to
complete.  One of the mallocs complains that it the system is out of memory.
At this point, top reports that there is still 1 GB of swap space remaining
and as far as my understanding goes, the mmaped space is using the space on
/scratch1 for swap.  After doing some research on the subject, I have found
a number of newsgroup posts to try things like changing vm.overcommit_memory
(which looks like it might work by looking at the kernel source).  This
didn't change anything.  I also was able to run the same app with the same
parameters with the same result on just 1 of the machines, oversubscribing
that machine...therefore using twice the memory.  I get to the same point
and fail just after the 300MB mark.

So, naturally, I am am at my wits end here.  I have a few questions that I
am sure some of you linux gurus can answer.

A.  Does the system have a limit on how much you can mmap?  If so, why does
it wait until I actually use the space to run out?
B.  Should the system be using the scratch disk to swap the shared heap?  I
assume it does since df is reporting space being used while running the app.
C.  Is there a limit on how much memory a process can ask for?
D.  Would changing the freepages limits help (currently 255 510 765),
buffermem?
E.  Could these limits be affected by I/O or network traffic?
F.  Are there any other limits that I am not thinking of?

Any help would be appreciated.

Thanks,
Jeff

