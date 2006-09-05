From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 05 Sep 2006 16:47:43 +0000
Subject: Re: [RFC][PATCH 3/9] actual generic PAGE_SIZE infrastructure
Message-Id: <1157474863.3186.6.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221606.40937644@localhost.localdomain>
	 <20060905112056.GJ17042@admingilde.org>
In-Reply-To: <20060905112056.GJ17042@admingilde.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Martin Waitz <tali@admingilde.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 2006-09-05 at 13:20 +0200, Martin Waitz wrote:
> On Wed, Aug 30, 2006 at 03:16:06PM -0700, Dave Hansen wrote:
> > * Define ASM_CONST() macro to help using constants in both assembly
> >   and C code.  Several architectures have some form of this, and
> >   they will be consolidated around this one.
> 
> arm uses UL() for this and I think this is much more readable than
> ASM_CONST().  Can we please change the name of this macro?

I don't have any real problem with changing it, but I fear that the ppc
guys will want it the _other_ way. ;)

Do you really mind if we just keep it as it is?  If there is some
further disagreement on it, I'll change it.

-- Dave

