From: Matthew Wilcox <willy@debian.org>
Date: Fri, 20 Feb 2004 02:33:43 +0000
Subject: The new radeon driver in 2.6.3
Message-Id: <20040220023343.GX11824@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I've had problems with the new RadeonFB driver with my Radeon 7000
card.  Turns out you need to enable I2C and then RADEON_I2C.  Then
it works nicely.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
