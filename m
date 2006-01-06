From: Arjan van de Ven <arjan@infradead.org>
Date: Fri, 06 Jan 2006 18:59:07 +0000
Subject: Re: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <1136573948.2940.65.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F055A7B6B@scsmsx401.amr.corp.intel.com>
	 <20060106174957.GF19769@parisc-linux.org>
	 <Pine.LNX.4.62.0601060958110.17665@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.58.0601061017510.11324@shark.he.net>
	 <Pine.LNX.4.62.0601061035510.17875@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601061035510.17875@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: "Randy.Dunlap" <rdunlap@xenotime.net>, Matthew Wilcox <matthew@wil.cx>, "Luck, Tony" <tony.luck@intel.com>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>


> Vendors look for the upstream defaults and orient themselves on the 
> defconfig.

they do? That's news to me. I've worked at a vendor for almost 5 years,
3 1/2 years of which I was the person who decided on the configs (with
external input of course). In those 3 1/2 years I *never* looked at
defconfig. *never*. And I don't expect other vendor kernel owners to do
things differently; when a config option needs deciding you look at the
description and pick a good value. That's it. Defconfig doesn't matter.

