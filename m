From: Matthew Wilcox <willy@debian.org>
Date: Fri, 03 Sep 2004 19:30:27 +0000
Subject: ACPI pci hotplug patch series
Message-Id: <20040903193027.GO642@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>, pcihpd-discuss@lists.sourceforge.net
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


A series of 5 patches coming up that make acpiphp work on an rx8620.
Unfortunately, they'll cause i386 to not work, so don't apply these
for now.

01-pci-bus-address.diff
Adds a way to convert from a global system address to a local pci bus address.

02-ia64-fixups.diff
Fix some bugs.  Nothing earth-shattering.

03-acpiphp-domains.diff
Make acpiphp handle domains properly

04-acpiphp-pcidev.diff
Prevent acpiphp from crashing the system in nasty untracable ways

05-acpiphp-misc.diff
Some minor cleanups

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
