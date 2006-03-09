From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 09 Mar 2006 00:21:37 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <Pine.LNX.4.64.0603081605590.10581@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 Mar 2006, Luck, Tony wrote:

> Thinking about this further ... in most cases the swap path will also
> conceal any evidence that this happened, because it will overwrite
> the pte with the swap file number and offset of where it stashed
> the page ... so "we've been lucky for all these years" theory is
> looking quite credible.

Hmm.... What happens for the dirty bit .... zero pte is marked dirty, 
however page is marked not present, thus page fault follows. By the time 
the fault handler checks the pte it is valid again since the 
swapper overwrote with a swap pte (otherwise we would get 
VM: killing process ...), swapper overwrites with swap pte. The 
fault is a write fauklt which restores the page and marks it dirty. Then 
the process writes to the page. So that seems to be okay.

But this only occurs for anonymous pages. If the page is file backed and 
zapped by the swapper then the pte is not rewritten again but the fault 
handler tries to "interpret" the strange pte.


