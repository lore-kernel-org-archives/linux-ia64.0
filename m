From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Mon, 05 Apr 2004 15:07:42 +0000
Subject: Re: Migrate pages from a ccNUMA node to another - patch
Message-Id: <4071763E.7293CFCC@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <40695802.1F13AB0D@nospam.org>
		<20040330.210804.71938972.taka@valinux.co.jp>
		<40698501.BD3E12BF@nospam.org> <20040403.115833.74749140.taka@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, iwamoto@valinux.co.jp

Hirokazu Takahashi wrote:

> I guess aruguments src_node, mm and pte would be redundant since
> they can be looked up from old_p with the reverse mapping scheme.

In my version 0.2, I can do with only the following arguments:
 *		node:	Destination NUMA node
 *		mm:	-> victim "mm_struct"
 *		pte:	-> PTE of the page to be moved
(If I have "mm" at hand, why not to use it ? Why not to avoid fetching the =
r-map
page struct ?)

> >Notes: "pte" can be NULL if I do not know it apriori
> >       I cannot release "mm->page_table_lock" otherwise I have to re-sca=
n the "mm->pgd".
>=20
> Re-schan plicy would be much better since migrating pages is heavy work.
> I don't think that holding mm->page_table_lock for long time would be
> good idea.

Re-scanning is "cache killer", at least on IA64 with huge user memory size.
I have more than 512 Mbytes user memory and its PTEs do not fit into the L2=
 cache.

In my current design, I have the outer loops: PGD, PMD and PTE walking; and=
 once
I find a valid PTE, I check it against the list of max. 2048 physical addre=
sses as
the inner loop.
I reversed them: walking through the list of max. 2048 physical addresses a=
s outer
loop and the PGD - PMD - PTE scans as inner loops resulted in 4 to 5 times =
slower
migration.

> How do you think about following algorism:
>   1. get mm->page_table_lock
>   2. chose some pages.
>   3. release mm->page_table_lock
>   4. call remap_onepage() against each page.
>   5. goto step1 if there remain pages to be migrated.

I want to move the most frequently used pages - at least with the HW assist=
ed
hot page detection.
I take "mm->page_table_lock", I nuke the PTE. We've got a good chance that =
the CPU
using the page observes a page fault almost immediately. It enters the page=
 fault
handler and gets blocked by "mm->page_table_lock". If I released the lock, =
the CPU
could continue and realize that there is nothing to do, the page fault has =
already
been repaired. In the mean time, it is me who wait for "mm->page_table_lock=
".
At worst this scenario happens 2048 times.
If I keep the lock, the victim CPU enters only once the page fault handler.

I think what we should do is to "pull in" pages in to a node rather than th=
an
"pushing them out" for two reasons:
- the recipient CPU executes the migration instead of busy waiting for the =
lock
- there is chance that the recipient CPU will find the migrated data useful
  in its cache

Regards,

Zolt=E1n Menyh=E1rt
