From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Feb 2003 07:09:03 +0000
Subject: Re: [Linux-ia64] Problem with elilo 3.3a
Message-Id: <marc-linux-ia64-105590709805849@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 13 Feb 2003 22:58:53 -0800, Stephane Eranian <eranian@frankl.hpl.hp.com> said:

  Stephane> Note that the memory map itself IS NOT allocated inside
  Stephane> the boot_param structure. This structure only contains a
  Stephane> pointer to it as well as the size of the region. The map
  Stephane> is dynamically allocated (in util.c).  The kernel
  Stephane> (arch/ia64/kernel/setup.c) assumes all "valid" memory
  Stephane> regions are free except for regions it knows about which
  Stephane> are: - the boot param struct - the memory map (address in
  Stephane> size in boot param struct) - initrd - command line string
  Stephane> - kernel code and data

That's not good.  The kernel assumes that the efi_memmap was copied
and happily scribbles over it.  I thought the bootloader used to make
a copy of the mem-map.  Am I misremembering?

	--david

