From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 18 Nov 2004 22:18:30 +0000
Subject: RE: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F026C5679@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I'm happy with k3, too.  What is the status of the patch?
>If I need to make changes to get the patch accepted, I will.  
>Otherwise, I'll get the next patch, building on this patch,
>ready to go.

The patch is not quite how I had envsioned it.  I'd thought that
you were going to point ar.k3 at the physical base of the whole percpu
area, not just at the data structure for the mca/init parts.
Then sprinkle in some syntactic sugar macros to access per-cpu
variables.  That way you can just use:

 DECLARE_PER_CPU(type, yourname);

to declare anything that you need replicated for each cpu (unless
they all add up to more than 64k ... then we'd have to do something
to make the bigger items just pointers in per_cpu space, and make
sure the actual space is allocated when cpus are found).

Using these in assembler comes down to computing

   ar.k3 + (&per_cpu__yourname - &__per_cpu_start)

Does that make sense?

-Tony
