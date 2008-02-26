From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 26 Feb 2008 23:07:29 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:113134fcbca83619be4c68d0ca66db6093
Message-Id: <20080226230729.GA5715@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 26, 2008 at 03:45:40PM -0700, Alex Chiang wrote:
> I looked through some SAL specs, and it turns out that
> SAL_PHYSICAL_ID_INFO was introduced in v3.2, but this tiger
> implements v3.1.
> 
> SAL *should* be returning -1 for unimplemented calls, but
> something is going fantastically wrong here. Bjorn pointed out
> that both r2 and b6 contain the IP. Maybe SAL isn't computing
> branches correctly or something?
> 
> So what to do to work around a broken SAL? Seems like a chicken
> and egg problem to me -- the only way to try and check if a call
> is implemented or not is to call it, and calling it hangs the
> machine... :(

While you can check to see what SAL revision is supported, do be wary
of some prototype HP SAL implementations which report numbers in the
60-90 range.  It's probably safe to say 'if sal revision < 3.2 answer -1', but we were burned with extended PCI config space many moons ago
when we said 'if sal > 3.1 use new method'.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
