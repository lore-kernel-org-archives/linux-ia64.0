From: "Santosh Abraham" <santosha@india.hp.com>
Date: Wed, 24 Aug 2005 04:36:41 +0000
Subject: RE: Large-page support
Message-Id: <009101c5a863$c18932f0$33d84c0f@asiapacific.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <007d01c5a7e8$b1103d90$33d84c0f@asiapacific.hpqcorp.net>
In-Reply-To: <007d01c5a7e8$b1103d90$33d84c0f@asiapacific.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for the info !

If I read it correctly the flags need to be
MAP_FIXED|MAP_SHARED ? No support for MAP_PRIVATE ?

Any good reading available on why we need
a hugetlbfs ? 

TIA,
-santosh.



> -----Original Message-----
> From: Luck, Tony [mailto:tony.luck@intel.com] 
> Sent: Tuesday, August 23, 2005 9:55 PM
> To: santosh.abraham@hp.com; linux-ia64@vger.kernel.org
> Subject: RE: Large-page support
> 
> 
> >What is the current level of large page support implemented 
> for Linux ?
> 
> Linux currently doesn't support "large" pages ... but it does 
> support "huge" ones.
> 
> On ia64 there is a kernel compile-time choice for the regular 
> page size between 4k, 8k, 16k and 64k.  The default is 16k.
> 
> Huge page size is selectable via a boot-time parameter 
> "hugepagesz=", choices are just about anything supported by 
> h/w (current implementations of Itanium 2 support even powers 
> of two up to 4G). Default is 256MB.
> 
> >Can applications specify a certain page-size to use for
> >their private mappings ? Is this limited to any particular 
> page-size ?
> 
> No ... normal allocations are done using the default system 
> page size.  To see how to use huge pages, read 
> Documentation/vm/hugetlbpage.txt in the Linux kernel sources.
> 
> >Is smart-demotion implemented ?
> No.
> 
> -Tony
> 
> 


