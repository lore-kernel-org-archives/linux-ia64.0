From: "Olivier, JeffreyX" <jeffreyx.olivier@intel.com>
Date: Fri, 02 Aug 2002 15:25:50 +0000
Subject: RE: [Linux-ia64] mmap and malloc questions on IA-64 linux
Message-Id: <marc-linux-ia64-105590701905884@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905877@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905877@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> - /proc/PID/maps (where PID is the process ids of the "interesting"
>	  tasks)

Thanks for the response.

/proc/PID/maps appears to be showing any entry for every single page in the
mapped files.  Is this normal?  Shouldn't there just be one map for the
whole file?  At any rate, the mappings appear to be in the address range
described in the next paragraph.

Also, I started printing  the addresses returned by malloc.  I map the files
starting at 0x6000000300000000.  The addresses for malloc are not getting
anywhere close to that limit.  However, something very peculiar happens.
Just before the failed malloc, the last 3 or 4 successful mallocs return
addresses in the 0x2000000000000000 range which is region 1 and should(?) be
reserved for shared memory (according to the figure on page 149 or your ia64
kernel book).  Any idea why this would happen.  I don't explicitly allocate
memory as shared.  At the point where this happens, the current brk is at
0x6000000000898000.  That is almost 12 GB from the first mmap.  


Here is the output of free just before it runs out of memory
             total       used       free     shared    buffers     cached
Mem:        952576     948448       4128          0        656     836416
-/+ buffers/cache:     111376     841200
Swap:      1542176     650992     891184

To explain the large number of cached pages, /proc/sys/vm/pagecache is
currently set to 
2       15      75

Thanks,
Jeff

