From: Grant Grundler <iod00d@hp.com>
Date: Mon, 03 May 2004 15:07:48 +0000
Subject: Re: shared memory between 32bit & 64bit applications
Message-Id: <20040503150748.GA26104@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040503132511.GJ2281@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040503132511.GJ2281@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, May 03, 2004 at 06:46:09PM +0530, ARADHYA, CHINMAYA TM (STSD) wrote:
> The 64 bit application fills in {1,5,5} in the shared
> memory and when I access these values from a 32 bit application
> I get it as {1,21474836480,0}.

Besides the different padding rules mentioned by willy, I'd
advise debugging with with hex output instead of decimal.
It makes it very obvious which bits are going where.

And do some experiments with filling in the fields with
known values and then dumping the entire struct as a byte array.

grant
