From: Matthew Wilcox <willy@debian.org>
Date: Tue, 13 Apr 2004 16:21:36 +0000
Subject: Re: oops in serial_out in 2.6.5
Message-Id: <20040413162136.GT18329@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413063757.GA11350@hp.com>
In-Reply-To: <20040413063757.GA11350@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 13, 2004 at 04:37:58PM +1000, Martin Pool wrote:
> I'm (trying to) run Debian's 2.6.5-mckinley-smp on an hp rx2600.  It
> oopses at startup in setserial.  The console is ttyS0, which points to
> the management processor.

I tend to purge setserial, it's just worthless.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
