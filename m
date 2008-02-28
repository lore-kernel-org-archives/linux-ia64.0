From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 28 Feb 2008 00:30:12 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:113134fcbca83619be4c68d0ca66db6093
Message-Id: <20080228003011.GC29360@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 27, 2008 at 10:50:25AM -0600, Russ Anderson wrote:
> On Tue, Feb 26, 2008 at 05:34:19PM -0700, Alex Chiang wrote:
> > > SAL 2.9: SGI SN2 version 1.30
> > 
> > I wouldn't expect SAL 2.9 to implement a call defined in SAL 3.2,
> > unless I'm seriously misunderstanding something?
> 
> The answer is the 2.9 value is hardcoded in the Altix prom and
> was not updated to 3.2 even though the prom supports SAL 3.2.

Sounds like we should just set the sal revision to 3.2 if
ia64_platform_is("sn2").  Would that cause any other problems?  What
about older versions of the prom?

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
