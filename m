From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 29 Apr 2004 22:08:15 +0000
Subject: Re: [patch 1/3] efivars driver update and move
Message-Id: <1083276494.8416.114.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <D36CE1FCEFD3524B81CA12C6FE5BCAB002FFEAB3@fmsmsx406.fm.intel.com>
	 <1083268253.8416.100.camel@localhost>
	 <20040429211930.GC15106@lists.us.dell.com>
In-Reply-To: <20040429211930.GC15106@lists.us.dell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Domsch <Matt_Domsch@dell.com>
Cc: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, akpm@osdl.org, linux-ia64 <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, 2004-04-29 at 15:19, Matt Domsch wrote:
> On Thu, Apr 29, 2004 at 01:50:54PM -0600, Alex Williamson wrote:
> > # stat BootOrder-8be4df61-93ca-11d2-aa0d-00e098032b8c\ /
> >   File: `BootOrder-8be4df61-93ca-11d2-aa0d-00e098032b8c /'
> 
> FWIW, my Intel Tiger2-based system doesn't have the space at the end...
> 
> >         *(short_name + strlen(short_name)) = '-';
> >         efi_guid_unparse(vendor_guid, short_name + strlen(short_name));
> >         *(short_name + strlen(short_name)) = ' ';
> 
> even though looking at this I would have expected it to...

   Yeah, I'm not sure how you couldn't have a space at the end...

> 
> Can you remove that last line and see what it does?  Best as I can
> tell, it isn't necessary or desired.

   Yes, removing that last line above gets rid of the space, everything
looks right, and efibootmgr doesn't complain.  I'd attach a patch but
I'm curious if Matt T. had some reason for adding it.

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

