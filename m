From: Dave Jones <davej@redhat.com>
Date: Thu, 14 Oct 2004 18:49:15 +0000
Subject: Re: [PATCH] General purpose zeroed page slab
Message-Id: <20041014184915.GE18321@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1oej5s0po.fsf@wilson.mkp.net> <416EB7AD.4040302@didntduck.org> <20041014173637.GQ16153@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041014173637.GQ16153@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Brian Gerst <bgerst@didntduck.org>, "Martin K. Petersen" <mkp@wildopensource.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, tony.luck@intel.com

On Thu, Oct 14, 2004 at 06:36:37PM +0100, Matthew Wilcox wrote:
 > On Thu, Oct 14, 2004 at 01:30:21PM -0400, Brian Gerst wrote:
 > > This doesn't work as you expect it does.  The constructor is only called 
 > > when a new slab is created, for each new object on the slab.  It is 
 > > _not_ run again when an object is freed.  So if a page is freed then 
 > > immediately reallocated it will contain garbage.
 > 
 > The user is responsible for zeroing the page before handing it back to
 > the slab allocator.

That sounds like an accident waiting to happen.
How about a CONFIG_DEBUG option to check its zeroed on free ?

		Dave

