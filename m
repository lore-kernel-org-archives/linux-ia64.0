From: Erich Focht <efocht@hpce.nec.com>
Date: Fri, 23 Jan 2004 10:45:20 +0000
Subject: Re: Loadable module and kernel gp
Message-Id: <200401231145.21011.efocht@hpce.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4010EEC0.7020003@hob.de>
In-Reply-To: <4010EEC0.7020003@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At compile time you can get it from the System.map. The symbol is at
the end and called __gp. Of course you might want to have some
cross-checks that you pick up the right System.map. I usually take
some known and exported symbols.

But there's surely some dynamic way, too...

Regards,
Erich

On Friday 23 January 2004 10:52, Christian Hildner wrote:
> does anybody know a simple way for a loadable module to get the gp value
> of the kernel? Is there any sample code?
>
> Christian


