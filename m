From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 18 Mar 2005 15:00:06 +0000
Subject: Re: [PATCH] add a clear_pages function to clear pages of higher
Message-Id: <Pine.LNX.4.58.0503180652350.15022@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503101229420.13911@schroedinger.engr.sgi.com>
 <200503111008.12134.vda@port.imtp.ilyichevsk.odessa.ua>
 <Pine.LNX.4.58.0503161720570.1787@schroedinger.engr.sgi.com>
 <200503181154.37414.vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200503181154.37414.vda@port.imtp.ilyichevsk.odessa.ua>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Cc: Dave Hansen <haveblue@us.ibm.com>, Andi Kleen <ak@muc.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, linux-ia64@vger.kernel.org, Jens.Maurer@gmx.net

On Fri, 18 Mar 2005, Denis Vlasenko wrote:

> NT stores are not about 5% increase. 200%-300%. Provided you are ok with
> the fact that zeroed page ends up evicted from cache. Luckily, this is exactly
> what you want with prezeroing.

These are pretty significant results. Maybe its best to use non-temporal
stores in general for clearing pages? I checked and Itanium has always
used non-temporal stores. So there will be no benefit for us from this
approach (we have 16k and 64k page sizes which may make the situation a
bit different). Try to update the i386 architectures to do the same?

Or for prezeroing, you could register a zeroing driver that would use the
non-temporal stores with V8 of the prezeroing patches. In any case the
clear_pages patch is not useful the way it was intended for us and I am
have dropped this from the prezeroing patch.

