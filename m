From: Paul Jackson <pj@sgi.com>
Date: Wed, 19 Nov 2003 21:45:30 +0000
Subject: Re: [PATCH] - prof_cpu_mask problems
Message-Id: <marc-linux-ia64-106927861710234@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106901123527791@msgid-missing>
In-Reply-To: <marc-linux-ia64-106901123527791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew wrote (on the linux-ia64 list):
> Why u16 rather than u32?

You'd probably have to ask whomever wrote that part in the first place.
I'd guess Jack was using u16 because it was already there.

My take - we should:
 1) change the loop to u32,
 2) add a separator character, say comma ',', between u32 words, and
 3) drop the zero %04x fill.
 
Then systems with NR_CPUS <= 32 would see a single hex number:
 "1"          if just cpu 0
 "80000000"   if just cpu 31
 
A full-up cpumask on a 512 CPU system would look like:

ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff

Typical systems with 4 or fewer CPUs would see masks ranging from
"1" to "f" (a single hex digit), and an empty mask of "0".

The user of a separator character becomes rather helpful for any
sort of human parsing on large systems, and is of no consequence
to those with 32 or fewer CPUs, which I am told is what most
poor deprived Linux programmers still have to cope with - sorry
<grin>.  Once a separator character is introduced, then one can
drop the zero-fill of each word, because one no longer needs
to explicitly display every digit to avoid ambiguous output.

For sparse masks on very large systems, these changes can be
a significant improvement, in my view.  An unbroken string of
128 hex digits is mind numbing.

Last night I posted the code snippet below on the
"format_cpumask()" thread of Bill Irwin's on lkml.  Bill, happy
to pass this tar baby onto me I suspect, replied "run with it".

I will try making the following into a real patch (just the
formatting stuff shown here, not the abstract data type,
for now).

The no-zero fill and the separator character are a tad different.

Speak up if you object ...

Special thanks to Christoph Hellwig for earlier comments (not
that he would necessarily approve of where I've taken this ...).

=
The following code provides the "," separated, no-zero fill,
flavor of this.  This comes from some work I am doing to provide
an abstract data type for a new nodemask_t type, that should
also work for cpumasks, with a nice little bit of code reduction
(but still nice inline assembly code in most cases).

The following "__mask_snprintf_len()" code would be called from
a macro, such as:

#define cpumask_snprintf(buf, buflen, cpumask) \
	__mask_snprintf_len(buf, buflen, cpumask_addr(cpumask), NR_CPUS/8)

where cpumask_addr(map) was one of:

	&(map)
    or
	(map).mask


int __mask_snprintf_len(char *buf, unsigned int buflen,
        unsigned int *maskp, unsigned int maskbytes)
{
        int i;
        int len = 0;
        unsigned int maskints = maskbytes/sizeof(unsigned int);
        char *sep;
        if (buflen < 2)
                return;
        if (maskints = 0) {
                strcpy(buf,"0");
                return 1;
        }
        buf[0] = 0;
        sep = "";
        for (i = maskints-1; i >= 0; i--) {
                int n = strlen(buf);
                len += snprintf(buf+n, buflen-n, "%s%x", sep, maskp[i]);
                sep = ",";
        }
        return len;
}


-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
