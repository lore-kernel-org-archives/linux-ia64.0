From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 02 Aug 2002 21:08:12 +0000
Subject: RE: [Linux-ia64] mmap and malloc questions on IA-64 linux
Message-Id: <marc-linux-ia64-105590701905890@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905877@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905877@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 2 Aug 2002 08:25:50 -0700 , "Olivier, JeffreyX" <jeffreyx.olivier@intel.com> said:

  Olivier> /proc/PID/maps appears to be showing any entry for every
  Olivier> single page in the mapped files.  Is this normal?
  Olivier> Shouldn't there just be one map for the whole file?  At any
  Olivier> rate, the mappings appear to be in the address range
  Olivier> described in the next paragraph.

Yes, normally there is one entry per mapped file.  If you use munmap()
and mmap() a lot, the merging-logic in the kernel may not be able to
keep up and then you'd get fragmented maps, even when they could be
merged in theory.  However, from what you have described so far, I do
not think this is something you'd be running into.  So something seems
strange here.

  Olivier> Also, I started printing the addresses returned by malloc.
  Olivier> I map the files starting at 0x6000000300000000.  The
  Olivier> addresses for malloc are not getting anywhere close to that
  Olivier> limit.  However, something very peculiar happens.  Just
  Olivier> before the failed malloc, the last 3 or 4 successful
  Olivier> mallocs return addresses in the 0x2000000000000000 range
  Olivier> which is region 1 and should(?) be reserved for shared
  Olivier> memory (according to the figure on page 149 or your ia64
  Olivier> kernel book).

It's true that region 1 is used for shared memory, but it's also use
for any mmap() for which you don't specify a mapping address, so this
by itself doesn't look suspicious.

  Olivier> Here is the output of free just before it runs out of
  Olivier> memory total used free shared buffers cached Mem: 952576
  Olivier> 948448 4128 0 656 836416 -/+ buffers/cache: 111376 841200
  Olivier> Swap: 1542176 650992 891184

Nothing obviously wrong here.  Clearly it's not an out-of-memory
situation.

Please provide a minimal test program that reproduces the problem.

Thanks,

	--david

