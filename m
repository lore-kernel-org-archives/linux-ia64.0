From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 08 Jun 2007 04:43:17 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <Pine.LNX.4.64.0706072141540.27597@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 7 Jun 2007, Luck, Tony wrote:

> On the filesystem front I recall someone saying that you
> could configure a 64K blocksize filesystem ... but then
> you would not be able to mount that on any other Linux
> machine.

Will be addressed by the Large Blocksize patchset. You can already mount 
it on other platforms that support 64k (powerpc).

