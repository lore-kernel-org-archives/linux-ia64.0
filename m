From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Mon, 14 Oct 2002 17:42:21 +0000
Subject: Re: [Linux-ia64] BitKeeper tree for 2.4.x
Message-Id: <marc-linux-ia64-105590709805158@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805154@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805154@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 14 October 2002 12:17 pm, Steffen Persvold wrote:
> Well, without MAP_WRITECOMBINED, streaming PIO accesses to the PCI bus 
> drops from 330MByte/sec to approx. 100MByte/s using the Dolphin SCI card. 
> 
> This is an rather significant drop which makes the IA64 platform kind of 
> uninteresting for high performance clustering (the Dolphin SCI cards are 
> used for shared memory message passing between nodes).
> 
> We can of course hack this in for our usage (in our kernel driver) if you 
> are totally against having it in the kernel headers, but I think since the 
> hardware allows different mapping types, the kernel should take advantage 
> of it.

I'm really not opposed to having it in the kernel headers.  The thing
is, we were allowing WC mappings regardless of whether the hardware
actually supported them.  What we need is some mechanism for
looking at the EFI memory map, which tells us what attributes are
supported.

We've got a mechanism for looking up the supported attributes
(efi_mem_attributes()); what I'd really like is for somebody to
hook that up with the mmap infrastructure so that we only allow
the supported attributes.

Bjorn


