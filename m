From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 06 Oct 2004 20:33:30 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <20041006203330.GH16153@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221C989@scsmsx401.amr.corp.intel.com> <41644301.9EC028B3@sgi.com> <20041006195424.GF25773@cup.hp.com> <200410061327.28572.jbarnes@engr.sgi.com>
In-Reply-To: <200410061327.28572.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: Grant Grundler <iod00d@hp.com>, Colin Ngam <cngam@sgi.com>, Patrick Gefre <pfg@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, Matthew Wilcox <matthew@wil.cx>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Oct 06, 2004 at 01:27:28PM -0700, Jesse Barnes wrote:
> Though now what's there seems awfully redundant, wouldn't you say?  Just 
> allowing direct access to pci_root_ops is a much simpler approach and gets 
> rid of a bunch of extra, unneeded code (i.e. closer to Pat's original 
> version).

now that I understand what's going on, I think it's better to make
pci_root_ops non-static.  Of course, it'd be better if SN2 used acpi to
discover its root busses, but I guess that'll take longer to implement.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
