From: Matthew Wilcox <willy@debian.org>
Date: Thu, 18 Mar 2004 23:50:24 +0000
Subject: [0/3] Make pci resources show up in iomem/ioport on ia64
Message-Id: <20040318235024.GH25059@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@zip.com.au>, Greg KH <greg@kroah.com>, David Mosberger <davidm@hpl.hp.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Matthew Wilcox <willy@debian.org>


I decided to do one simple little thing -- make PCI device resources show
up in /proc/iomem and /proc/ioport on ia64 just like they do on i386.
Of course, I found two bugs in the process so we have three logically
separate patches that I shall be sending in reply to this message.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
