From: Matthew Wilcox <willy@debian.org>
Date: Thu, 12 Aug 2004 11:55:51 +0000
Subject: Re: Altix I/O code reorganization - 11 of 21
Message-Id: <20040812115551.GO5387@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408112331.i7BNVsWk140739@fsgi900.americas.sgi.com>
In-Reply-To: <200408112331.i7BNVsWk140739@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hch@infradead.org

On Wed, Aug 11, 2004 at 06:31:54PM -0500, Pat Gefre wrote:
> +# Makefile for the sn2 io routines.
> +
> +obj-y				:=  klconflib.o

I agree with Christoph.  It's ridiculous to have one file per directory
like this.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
