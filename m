From: Jesse Barnes <jbarnes@redhat.com>
Date: Wed, 19 May 2004 13:21:31 +0000
Subject: Re: Disable CONFIG_SMP for IA64_HP_SIM
Message-Id: <200405190921.31175.jbarnes@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040519012326.GA27655@cse.unsw.EDU.AU>
In-Reply-To: <20040519012326.GA27655@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, May 18, 2004 11:10 pm, Ian Wienand wrote:
> On Wed, May 19, 2004 at 02:59:13AM +0100, Matthew Wilcox wrote:
> > On Tue, May 18, 2004 at 06:35:12PM -0700, David Mosberger wrote:
> > > CONFIG_SMP probably shouldn't depend on CONFIG_IOSAPIC.
> >
> > I agree -- I think the SGI machines don't have an IOSAPIC.
>
> I don't think it would effect the SGI machines as they have their own
> arch/sn/kernel/irq.c?

The patch looks fine.  sn2 still needs iosapic though (ACPI support relies on 
it), but that's a seperate issue.

Jesse
