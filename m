From: grundler@cup.hp.com (Grant Grundler)
Date: Wed, 09 Apr 2003 00:42:59 +0000
Subject: Re: [Linux-ia64] mmap crashes system after mapping PCI device into user space and reading and writin
Message-Id: <marc-linux-ia64-105590723705443@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 08, 2003 at 05:59:56PM -0400, Mike Fox wrote:
...
> Has anyone tried using mmap to remap PCI device memory into user space?  I
> have seen the following problem:  If I do the mmap, it returns successfully,
> and I can indeed access the device memory.  Unfortunately, the system will
> hang within about a minute after doing so.
...

David Mosberger passed on a very short program who's essence is:
  mem = mmap (NULL, page_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, offset);
  if (mem = MAP_FAILED)
  {
    perror ("memmap");
    exit (-1);
  }

This works on the HP ZX1 platforms with 2.4.20+patches kernel.

Be warned, it's *very* easy to crash a machine when using /dev/mem
and scribbling in misc parts of IO space. The symptom will typically
be an MCA (see "errdump MCA" output from EFI to get the xip).

grant

