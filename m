From: Hugh Dickins <hugh@veritas.com>
Date: Fri, 04 Mar 2005 19:08:30 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <Pine.LNX.4.61.0503041850170.24212@goblin.wat.veritas.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com> 
    <Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com> 
    <20050302174507.7991af94.akpm@osdl.org> 
    <Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com> 
    <20050302185508.4cd2f618.akpm@osdl.org> 
    <Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com> 
    <20050302201425.2b994195.akpm@osdl.org> 
    <Pine.LNX.4.58.0503022021150.3816@schroedinger.engr.sgi.com> 
    <20050302205612.451d220b.akpm@osdl.org> 
    <Pine.LNX.4.58.0503022206001.4389@schroedinger.engr.sgi.com> 
    <20050302222008.4910eb7b.akpm@osdl.org> 
    <Pine.LNX.4.58.0503030852490.8941@schroedinger.engr.sgi.com> 
    <20050303132011.7c80033d.akpm@osdl.org> 
    <Pine.LNX.4.58.0503040842200.17556@schroedinger.engr.sgi.com> 
    <Pine.LNX.4.61.0503041704510.4954@goblin.wat.veritas.com> 
    <Pine.LNX.4.58.0503041004020.18056@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503041004020.18056@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, 4 Mar 2005, Christoph Lameter wrote:
> On Fri, 4 Mar 2005, Hugh Dickins wrote:
> > Nacked for the same reason as just given to earlier version.  Ugly too.
> 
> Ok. Then we could still get back the also ugly solution in the earlier
> patchsets that acquired the spinlock separately before getting to
> do_wp_page (also no need for the separate patch anymore). Patch is
> then shorter too.

Maybe.  I should make it clear that I simply haven't examined the
recent incarnations of your patch, was just commenting on an issue
I could comment on quickly without needing to find time to think.

So, I just want to make clear, this absence of Nack doesn't mean
Ack: I remain uneasy with it all, waiting to see some architecture
maintainers come along with a clear "Yes, this is how it should be".

Hugh
