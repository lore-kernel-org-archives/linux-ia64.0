From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 22 Nov 2002 20:07:43 +0000
Subject: Re: [Linux-ia64] New rev 2.1 SDM for Itanium published
Message-Id: <marc-linux-ia64-105590709805479@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 22 November 2002 11:27 am, David Mosberger wrote:
> >>>>> On Fri, 22 Nov 2002 10:08:39 -0800, "Jim Hull" <jim_hull@hp.com> said:
> 
>   >> If so, should this be noted somewhere so that naive
>   >> people who read the manuals don't assume that it's implemented?
> 
>   Jim> There is a new "ao" bit in CPUID[4], which as described on p. 1:32, will
>   Jim> be 1 only if the new larger atomic ops are implemented.  Do you think
>   Jim> this is insufficient?
> 
> The ao bit seems to have gotten lost in the final version of SDM2.1.
> It's mentioned (indirectly) in the Document Revision history, but in
> the CPUID[4] description, only "branchlong" and "spontaneous deferral"
> show up.

Also, seems like the cmp8xchg16 instruction description ought to
mention that not all implementations support the instruction.
At least, that's what was done for "brl".

-- 
Bjorn Helgaas - bjorn_helgaas at hp.com
Linux and Open Source Lab
Hewlett-Packard Company

