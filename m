From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 Oct 2004 19:27:50 +0000
Subject: RE: RFC - freeing up ar.k5
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0221C912@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
In-Reply-To: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>Instead of using ar.k3 for a pointer to MCA/INIT information,
>does it make more sense to have ar.k3 be a pointer to the cpu_info
>structure, and add to the cpu_info structure a pointer to the mca_cpu
>structure?  The pointers would be physical addresses, so the assember
>code could add offsets to get the correct fields.  This would add
>only a little more complexity to access the mca data, but would
>make it easier for other assembler code access to the cpu_info
>structure.

I was imagining that ar.k3 would point to the physical address
of the percpu area.  Then you could declare anything you wanted
to use in MCA/INIT handlers in physical mode as PERCPU variables
and access them as "ar.k3 + (&variable - &__per_cpu_start)".
Some sort of macros to provide a little syntactic sugar would
make that fairly legible.

That way we don't clutter up cpu_info with random things. It also
uses ar.k3 in the most generic way possible.

-Tony
