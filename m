From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 29 Apr 2008 14:17:15 +0000
Subject: Re: [PATCH 1/2] mm: Avoid putting a bad page back on the LRU
Message-Id: <20080429071715.5d39d9c1@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080428192358.GB14629@sgi.com>
	<20080429143329.3a17ef91.akpm@linux-foundation.org>
In-Reply-To: <20080429143329.3a17ef91.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russ Anderson <rja@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, tony.luck@intel.com, clameter@sgi.com

On Tue, 29 Apr 2008 14:33:29 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 28 Apr 2008 14:23:58 -0500
> Russ Anderson <rja@sgi.com> wrote:
> 
> > --- test.orig/include/linux/kernel.h	2008-04-25
> > 15:22:07.640501421 -0500 +++ test/include/linux/kernel.h
> > 2008-04-25 15:42:02.826266036 -0500 @@ -412,6 +412,7 @@ struct
> > sysinfo { unsigned long totalhigh;	/* Total high memory size
> > */ unsigned long freehigh;		/* Available high memory
> > size */ unsigned int mem_unit;		/* Memory unit size
> > in bytes */
> > +	unsigned int badpages;		/* Number of bad
> > (PG_memerror) pages */ char
> > _f[20-2*sizeof(long)-sizeof(int)];	/* Padding: libc5 uses
> > this.. */ };
> 
> eek.  sys_sysinfo() copies this structure out to userspace verbatim. 
> Increasing its size by four bytes will cause memory scribbles in
> userspace applications.

not if you also reduce the padding ??


