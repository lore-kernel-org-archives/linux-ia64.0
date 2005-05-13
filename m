From: Ray Bryant <raybry@engr.sgi.com>
Date: Fri, 13 May 2005 10:20:27 +0000
Subject: elf header bits for page migration support......
Message-Id: <42847F6B.3080609@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

As some of the readers of this list may know, I've been working on a
"manual page migration" facility for Altix.   Basically this is intended
to allow a batch manager to move applications around on a large NUMA
system.  Further details and discussion can be found on the linux-mm
lists, for example the thread starting at:

http://marc.theaimsgroup.com/?l=linux-mm&m1578651020174&w=2

Now given the existence of the memory migration code in the memory
hotplug patch, the hard part of this project is not doing the migration,
but figuring out what not to migrate (e. g. one doesn't want to migrate
the shared pages of a shared library, for example).  Currently, we are
flagging files as libraries by using a file system extended attribute.
But this is meeting with some resistance.

The alternative being suggested is to mark the elf header of object files
that should only have shared pages migrated, or that should not be migrated
(e. g. you don't want to migrate /bin/csh all the time.)

(We'll extend mmap() with a similar set of flags.)

So the question has come up, which bits in the elf header are available
for such use.  Apparently there is a bit of a muddle here and we need to
get the "community" to agree.

So, I'm starting with linux-ia64.  Here's a specific question to get the
ball rolling:

Can I use some bits (I need 2) of p_flags of Elf64_Phdr for this purpose?
If so, which bits?

If not which other fields can I use?

Note:  The kernel and ld.so have to both be able to find the bits
relatively easily.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
