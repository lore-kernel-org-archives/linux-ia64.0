From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 14 Dec 2001 18:54:30 +0000
Subject: Re: [Linux-ia64] Linux page tables and VHPT
Message-Id: <marc-linux-ia64-105590698805695@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805693@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805693@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Dec 2001 14:21:43 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Hi all!  After reading and understanding (that took some
  Christian> time) the VHPT feature I

  Christian> looked through the sources, but there are some questions
  Christian> left about the use of the processor's VHPT.
  Christian> - which of the page tables are used as base address in cr.pta?

pta is always set to a fixed address.  The address is calculated based
on the number of address bits supported by the CPU.

  Christian> - where is the virtual page table located?

Each region that uses the VHPT has its own virtual page table, at the
offset configured in cr.pta.

  Christian> - which size has the virtual page table?

See above.

  Christian> - is the VHPT used for both the kernel and the userspace mappings?

Yes. ;-)

Regions 6 and 7 don't use the VHPT, the remaining regions do
(including region 5, which is the page-table mapped region of the
kernel).

  Christian> If anyone knows answers to my questions you'd be welcome.

My book describes this in a fair amount of detail.  It's not out yet,
but will be starting in February.  For table-of-contents etc., see the
URL below.

	--david

-- 
Interested in learning more about IA-64 Linux?  Try http://www.lia64.org/book/

