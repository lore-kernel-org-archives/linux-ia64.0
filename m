From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Date: Thu, 14 Oct 2004 19:08:49 +0000
Subject: Re: [PATCH] General purpose zeroed page slab
Message-Id: <200410142208.49831.vda@port.imtp.ilyichevsk.odessa.ua>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1oej5s0po.fsf@wilson.mkp.net> <20041014173637.GQ16153@parcelfarce.linux.theplanet.co.uk> <20041014184915.GE18321@redhat.com>
In-Reply-To: <20041014184915.GE18321@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Jones <davej@redhat.com>, Matthew Wilcox <matthew@wil.cx>
Cc: Brian Gerst <bgerst@didntduck.org>, "Martin K. Petersen" <mkp@wildopensource.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, tony.luck@intel.com

On Thursday 14 October 2004 21:49, Dave Jones wrote:
> On Thu, Oct 14, 2004 at 06:36:37PM +0100, Matthew Wilcox wrote:
>  > On Thu, Oct 14, 2004 at 01:30:21PM -0400, Brian Gerst wrote:
>  > > This doesn't work as you expect it does.  The constructor is only called 
>  > > when a new slab is created, for each new object on the slab.  It is 
>  > > _not_ run again when an object is freed.  So if a page is freed then 
>  > > immediately reallocated it will contain garbage.
>  > 
>  > The user is responsible for zeroing the page before handing it back to
>  > the slab allocator.

BTW, zeroing with non-temporal stores may be a huge win here.
It is 300% faster on Athlon.

> That sounds like an accident waiting to happen.
> How about a CONFIG_DEBUG option to check its zeroed on free ?
--
vda

