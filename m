From: Matthew Wilcox <willy@debian.org>
Date: Tue, 02 Mar 2004 17:57:01 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <20040302175701.GM25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 02, 2004 at 09:42:33AM -0800, David Mosberger wrote:
> >>>>> On Tue, 2 Mar 2004 15:56:01 +0000, Matthew Wilcox <willy@debian.org> said:
> 
>   Matthew> I don't have an objection to doing that, but how about
>   Matthew> making it Just Work for this particular case?  Something
>   Matthew> like ..
> 
> Well, that would be more convenient for me, but I don't know how many
> other "strange" SAL version numbers are out there in the wild.  It's
> can be handy to have an override option when dealing with buggy
> firmware (fortunately, quite rare with production systems, but it's
> all to common with prototypes).

Yeah.  That's why I moved it into a separate function so we can add
other bad version numbers.  If we were really keen, we could even add a
check for the oem and product IDs matching, or a data table of known-bad
BIOSes but let's keep it simple until we have to make it complex.

> Just a caveat:
> 
>   Matthew> SAL_VERSION_CODE(49, 29)
> 
> shouldn't these be in hex?

Nope, that's the beauty of it:

#define SAL_VERSION_CODE(major, minor) ((BIN2BCD(major) << 8) | BIN2BCD(minor))

BIN2BCD is defined in linux/bcd.h as ((((val)/10)<<4) + (val)%10)

So you get to specify things in decimal.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
