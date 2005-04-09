From: Arthur Kepner <akepner@sgi.com>
Date: Sat, 09 Apr 2005 00:34:20 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random
Message-Id: <Pine.LNX.4.61.0504081731590.20159@linux.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Fri, 8 Apr 2005, Matt Mackall wrote:

> .... random.c now uses fls and fls(0) was causing all
> the entropy to vanish.
> ....

Yeah, I always had my doubts about the Second Law of 
Thermodynamics....

--
Arthur
