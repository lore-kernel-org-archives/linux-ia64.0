From: Bruno Vidal <bruno_vidal@hp.com>
Date: Wed, 14 May 2003 06:50:50 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705782@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Hi
Many thanks, it seems that my question was interresting.
I just want to answer to some point:
> 
> But you also need to know which disk to write to, and where.  And
> presumably "which disk" actually means knowing the PCI path to the
> SCSI host adapter, and then the path to the disk.  "Where" might be
> just the index of start block, if you reserved a contiguous partition,
> or it might be more complex.  If any of this got screwed up, you might
> write your dump over /home instead -- and then rather than a possibly
> once-off kernel crash, you've lost lots of data.

HP-UX is already doing that. It keep in memory where to put the dump, and
the best place is swap partition. And it is really easy to verify before writing
that we are at the right place by checking any swap magic number in order to
avoid any overwriting (with linux it is really easy to check that).
And about the PCI path, it is not so hard to find it, and I saw that EFI provide
a function to retrieve the media ID by using the hardware path. Now it is clear
that in case of hardware failure  their is still cases where it avoid to take dumps,
but I never heard/seen HP-UX overwriting data while dumping, even in case of memory
corruption.

Now there is some other solution in order to take a dump. It is another path
I didn't try yet but if you can say what you think about it:
1. dump module reserve some amount of memory at the end of the memory (1Mb)
2. system call panic()
3. dump module start to compress memory, starting by the last address (without
the pages reserved by the module), and put the result in the last reserved pages
4. free the compressed pages, and then compress new pages to put it in freed pages
and so on until no more pages to compress
5. put a flag somewhere in NVRAM (or elsewhere)
6. do a warm boot in order to not reset the memory, and the compress memory
dump pages must be marked as allocated be the new kernel.
7. now we have a brand new running kernel with all drivers and a bunch of
memory pages that contain the dump, so we can push it directly on filesystem

The main problem with this kind of dump, is that it is not possible to takes
early dumps. It means also that firmware is able to reboot without modifying
any memory pages, it mean also that the kernel is able at boot time to flag
a large amount of pages as allocated. But the good effects are: a quick dump
(only memory access), a system up and running fairly fast (with less memory
at boot time but for a short periode of time). It can be a good choice for
critical application that require a low donwtime, and that have often a large
amount of memory (if you already try to dump a superdome with 64Gb by using
PDC call you understand what I mean).

	Cheers.

-- 
	Vidal Bruno, (770-4271)
         SSD-HA Team, HP-UX & LINUX Support
	bruno_vidal@hp.com


