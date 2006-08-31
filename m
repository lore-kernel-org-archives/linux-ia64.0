From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 31 Aug 2006 19:51:23 +0000
Subject: Re: [RFC][PATCH 2/9] conditionally define generic get_order()
Message-Id: <1157053883.28577.19.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221605.CFC342D7@localhost.localdomain>
	 <1defaf580608311141j39aa87e5ldf80db1db54b2edf@mail.gmail.com>
In-Reply-To: <1defaf580608311141j39aa87e5ldf80db1db54b2edf@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 2006-08-31 at 20:41 +0200, Haavard Skinnemoen wrote:
> On 8/31/06, Dave Hansen <haveblue@us.ibm.com> wrote:
> > diff -puN mm/Kconfig~generic-get_order mm/Kconfig
> > --- threadalloc/mm/Kconfig~generic-get_order    2006-08-30 15:14:56.000000000 -0700
> > +++ threadalloc-dave/mm/Kconfig 2006-08-30 15:15:00.000000000 -0700
> > @@ -1,3 +1,7 @@
> > +config ARCH_HAVE_GET_ORDER
> > +       def_bool y
> > +       depends on IA64 || PPC32 || XTENSA
> > +
> 
> I have a feeling this has been discussed before, but wouldn't it be
> better to let each architecture define this in its own Kconfig?

As long as the conditions are simple, I think it would be nice to keep
it this way.  It makes it pretty obvious to tell what is going on from
_one_ place.  

> At some point, I have to add AVR32 to that list, and if one or more
> other architectures need to do the same, there will be rejects.

True, there will be rejects.  But, do you think they will actually take
more than a moment to merge?

-- Dave

