From: "Ameya Mitragotri" <ameya.mitragotri@wipro.com>
Date: Tue, 11 Nov 2003 05:14:42 +0000
Subject: RE: Problem with accessing page tables
Message-Id: <marc-linux-ia64-106852741506159@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106826502101883@msgid-missing>
In-Reply-To: <marc-linux-ia64-106826502101883@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Ameya> Now I think the memory for the swapper_pg_dir has 
> already been
>   Ameya> allocated.
>   Ameya> I still get PMD as 0.
> 
> Again, that's normal for memory that hasn't been allocated yet.
> 
>   Ameya> Am I doing something fundamentally wrong?
> 
> I don't know.  What exactly are you trying to do?

Our assumption is that the addresses for the global variables 
will surely be allocated.
(e.g. &panic_timeout should always resolve to an available PGD,PMD,PTE
and
in the end to a page.)
But we see that it is not happening in our case. (In case of
swapper_pg_dir 
one page is already allocated so it should point to a valid page).
Any valid address which we have taken from System.map does not resolve
down to a 
valid PTE. (??)

The whole purpose of this being, We want to simulate the page tables at
user level
to analyse a crash dump (LKCD) on IA64. So we dump the page tables and
when
Lcrash (the user mode tool for analysing dumps) reads this dump, it can
seek the
page tables and access global variables accordingly. This also will help
us eventually 
in unwinding the dumped stack.

Thanks
Ameya
