From: Steffen Persvold <sp@scali.com>
Date: Thu, 17 Oct 2002 18:16:48 +0000
Subject: Re: [Linux-ia64] BitKeeper tree for 2.4.x
Message-Id: <marc-linux-ia64-105590709805185@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805154@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805154@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 14 Oct 2002, Bjorn Helgaas wrote:

> On Monday 14 October 2002 12:17 pm, Steffen Persvold wrote:
> > Well, without MAP_WRITECOMBINED, streaming PIO accesses to the PCI bus 
> > drops from 330MByte/sec to approx. 100MByte/s using the Dolphin SCI card. 
> > 
> > This is an rather significant drop which makes the IA64 platform kind of 
> > uninteresting for high performance clustering (the Dolphin SCI cards are 
> > used for shared memory message passing between nodes).
> > 
> > We can of course hack this in for our usage (in our kernel driver) if you 
> > are totally against having it in the kernel headers, but I think since the 
> > hardware allows different mapping types, the kernel should take advantage 
> > of it.
> 
> I'm really not opposed to having it in the kernel headers.  The thing
> is, we were allowing WC mappings regardless of whether the hardware
> actually supported them.  What we need is some mechanism for
> looking at the EFI memory map, which tells us what attributes are
> supported.

Which IA64 hardware doesn't support _PAGE_MA_WC in the PTE ? My IA64 docs 
doesn't mention anything about that.

> 
> We've got a mechanism for looking up the supported attributes
> (efi_mem_attributes()); what I'd really like is for somebody to
> hook that up with the mmap infrastructure so that we only allow
> the supported attributes.

Actually I think _PAGE_MA_WC is only applicable to IO memory the same way 
as _PAGE_MA_UC is. Can't it be handled in the same way ? (you've already 
done the fix for UC, right ?)

Regards,
-- 
  Steffen Persvold   |       Scali AS      
 mailto:sp@scali.com |  http://www.scali.com
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY



