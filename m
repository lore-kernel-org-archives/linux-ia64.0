From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 14 Oct 2004 17:36:37 +0000
Subject: Re: [PATCH] General purpose zeroed page slab
Message-Id: <20041014173637.GQ16153@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1oej5s0po.fsf@wilson.mkp.net> <416EB7AD.4040302@didntduck.org>
In-Reply-To: <416EB7AD.4040302@didntduck.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brian Gerst <bgerst@didntduck.org>
Cc: "Martin K. Petersen" <mkp@wildopensource.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, tony.luck@intel.com

On Thu, Oct 14, 2004 at 01:30:21PM -0400, Brian Gerst wrote:
> This doesn't work as you expect it does.  The constructor is only called 
> when a new slab is created, for each new object on the slab.  It is 
> _not_ run again when an object is freed.  So if a page is freed then 
> immediately reallocated it will contain garbage.

The user is responsible for zeroing the page before handing it back to
the slab allocator.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
