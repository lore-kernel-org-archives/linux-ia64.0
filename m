From: Keith Owens <kaos@ocs.com.au>
Date: Sun, 06 Jan 2002 11:55:17 +0000
Subject: Re: [Linux-ia64] Re: Status on ioremap patch
Message-Id: <marc-linux-ia64-105590698805753@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805186@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805186@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 06 Jan 2002 12:02:01 +0100, 
Steffen Persvold <sp@scali.no> wrote:
>Keith Owens wrote:
>> 
>> On Sat, 05 Jan 2002 16:01:29 +0100,
>> Steffen Persvold <sp@scali.no> wrote:
>> >--- linux-2.4.17/mm/memory.c.orig      Fri Dec 21 18:42:05 2001
>> >+++ linux-2.4.17/mm/memory.c   Sat Jan  5 13:13:26 2002
>> >@@ -791,6 +791,9 @@
>> >  * maps a range of physical memory into the requested pages. the old
>> >  * mappings are removed. any references to nonexistent pages results
>> >  * in null mappings (currently treated as "copy-on-access")
>> >+ *
>> >+ * For physical (or I/O) memory mapped into the kernel virtual space,
>> >+ * the old mappings will not be removed.
>> 
>> That comment worries me.  If you have multiple mappings for the same
>> page then you may have problems on hardware that uses virtually indexed
>> caches.  Two virtual addresses could map to the same physical page but
>> index to different cache lines, destroying cache coherency.  How do you
>> prevent that?
>> 
>
>Well, actually multiple mappings in kernel space is denied :
>
>+               if (address > VMALLOC_START && address < VMALLOC_END) {
>+                       if (!pte_none(*pte)) {
>+                               printk("remap_area_pte: page already exists\n");
>+                               BUG();
>+                       }
>+                       set_pte(pte, mk_pte_phys(phys_addr, prot));
>+               } else {
>+                       struct page *page;
>+                       pte_t oldpage;
>+                       oldpage = ptep_get_and_clear(pte);
>+
>+                       page = virt_to_page(__va(phys_addr));
>+                       if ((!VALID_PAGE(page)) || PageReserved(page))
>+                               set_pte(pte, mk_pte_phys(phys_addr, prot));
>+                       forget_pte(oldpage);
>+               }

What about one mapping in kernel space and one in user space, or two
mappings in user space?  As long as you have more than one mapping to
the same physical page you must handle virtual cache aliasing.


