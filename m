From: Matthew Wilcox <matthew@wil.cx>
Date: Sun, 20 Feb 2005 15:57:43 +0000
Subject: Re: IA64 memory
Message-Id: <20050220155743.GA32640@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <851caabb05020220513945437@mail.gmail.com>
In-Reply-To: <851caabb05020220513945437@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Feb 20, 2005 at 04:48:50PM +0530, Vaibhav Sharma wrote:
> The memory map from efi is also defined for locations more than that
> which is available (I had 6GB of RAM on the machine, but the memory
> map covered addresses more than 6GB). I could not understand why it
> does so...

The memory in the machine isn't necessarily contiguous.  For example, an
hp zx1 machine would map 6GB of memory at 0-1GB then 257-260GB, then 4-6GB

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
