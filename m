From: Dean Nelson <dcn@sgi.com>
Date: Tue, 22 Mar 2005 12:37:58 +0000
Subject: Re: [PATCH] move cnodeid_to_nasid_table out of pda
Message-Id: <20050322123758.GA12064@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <423F2342.mailxGRL11RVD3@aqua.americas.sgi.com>
In-Reply-To: <423F2342.mailxGRL11RVD3@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 21, 2005 at 08:42:58PM -0800, Christoph Lameter wrote:
> > On Mon, 21 Mar 2005, Dean Nelson wrote:
> >
> > > Another step in the effort to eliminate the SN pda structure.
> > > This patch moves the cnodeid_to_nasid_table field out of the pda,
> > > making it a standalone per-cpu data item, and exports it so it can
> > > be accessed by kernel modules.
> 
> Yuck something went wrong with the test. Turns out that I need a lot more
> definitions to make mmtimer a module since it uses the SHUB access macros.
> The following patch applies on top of Dean's patch:

You're missing a patch from Jack Steiner that basically does what you
are trying to do in this patch. Jack's patch can be found at:

	http://lia64.bkbits.net:8080/linux-ia64-test-2.6.12

and is about 14 days old entitled:

	[IA64-SGI] [PATCH 2/2] - New chipset support for SN platform

In this patch he moved the following fields out of the pda and into their
own per-cpu data structure called sn_hub_info_s, the pointer to which is
exported.

-       u16             nasid_bitmask;
-       u8              shub2;
-       u8              nasid_shift;
-       u8              as_shift;
-       u8              shub_1_1_found;

I suggest you get that patch.

I'm also in the process of creating a patch to separate the nodepda from
the pda and export the phys_cpuid array of structures. This will allow
modules to use cpuid_to_nasid(cpuid).
