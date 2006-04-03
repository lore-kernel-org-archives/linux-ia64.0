From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 03 Apr 2006 18:27:50 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <Pine.LNX.4.64.0604031126000.21064@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 3 Apr 2006, Zoltan Menyhart wrote:

> It is very much curious having so few dirty and i-access traps...

The dirty bit handler is only used for sharable writable mappings. There 
are only very few pieces of software using such mappings. The kernel 
usually attempts to prepopulate ptes with bits set so that the dirty fault 
is avoided. F.e. a no page fault attempted for a write will install a 
dirty pte.


