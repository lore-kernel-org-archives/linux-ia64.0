From: Stephen Smalley <sds@epoch.ncsc.mil>
Date: Thu, 18 Mar 2004 21:22:47 +0000
Subject: Re: [Lse-tech] Re: Hugetlbpages in very large memory
Message-Id: <1079644967.12704.216.camel@moss-spartans.epoch.ncsc.mil>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com> <20040313034840.GF4638@wotan.suse.de>
	 <20040313184547.6e127b51.akpm@osdl.org>
	 <20040314040634.GC19737@krispykreme>
	 <37640233.1079550324@42.150.104.212.access.eclipse.net.uk>
	 <20040318122524.3904db7d.akpm@osdl.org>
In-Reply-To: <20040318122524.3904db7d.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Andy Whitcroft <apw@shadowen.org>, anton@samba.org, ak@suse.de, raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>, mbligh@aracnet.com

On Thu, 2004-03-18 at 15:25, Andrew Morton wrote:
> Seems reasonable, although "vm_enough_acctdom" makes my eyes pop.  Why not
> keep the "vm_enough_memory" identifier?
> 
> I've asked Stephen for comment - assuming he's OK with it I'd ask you to
> finish this off please.

To keep the name, he needs to update all callers, right?  Current patch
appears to add a static inline for security_vm_enough_memory that
retains the old interface to avoid having to update most callers.

I don't have any fundamental problem with the nature of the change.  As
a side note, patch was malformed (at least as I received it), not sure
if that was just a problem on my end.

-- 
Stephen Smalley <sds@epoch.ncsc.mil>
National Security Agency

