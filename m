From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Fri, 06 Jan 2006 20:17:46 +0000
Subject: Re: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <1136578666.2548.1.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F055A7B6B@scsmsx401.amr.corp.intel.com>
	 <20060106174957.GF19769@parisc-linux.org>
	 <Pine.LNX.4.62.0601060958110.17665@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.58.0601061017510.11324@shark.he.net>
	 <Pine.LNX.4.62.0601061035510.17875@schroedinger.engr.sgi.com>
	 <1136573948.2940.65.camel@laptopd505.fenrus.org>
In-Reply-To: <1136573948.2940.65.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arjan van de Ven <arjan@infradead.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, "Randy.Dunlap" <rdunlap@xenotime.net>, Matthew Wilcox <matthew@wil.cx>, "Luck, Tony" <tony.luck@intel.com>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>

On Gwe, 2006-01-06 at 19:59 +0100, Arjan van de Ven wrote:
> things differently; when a config option needs deciding you look at the
> description and pick a good value. That's it. Defconfig doesn't matter.

defconfig is 'Linus config', and he's stated as much before along with
polite hints that this wasn't going to change. The vendor default config
s are actually far saner for most users.

Do vendors look at defconfig - not really, much more interesting is
every other vendors config choices 8)

Alan

