From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Dec 2017 22:14:40 +0000
Subject: Re: Does this break IA64 Linux?
Message-Id: <20171208221439.ucfahr4gvv77jnsd@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F7B2CC912@ORSMSX110.amr.corp.intel.com>
 <151274828931.9961.17801232134228415862.stgit@warthog.procyon.org.uk>
 <151274828194.9961.4230316917108602662.stgit@warthog.procyon.org.uk>
 <10175.1512748454@warthog.procyon.org.uk>
 <31453.1512759888@warthog.procyon.org.uk>
In-Reply-To: <31453.1512759888@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Howells <dhowells@redhat.com>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 08, 2017 at 07:04:48PM +0000, David Howells wrote:
> Luck, Tony <tony.luck@intel.com> wrote:
> 
> > Which patch is "this patch". I don't see any link or attachment.
> 
> Sorry, I cc'd a patch which I sent to the ia64 list.  The 5th patch on this
> branch:
> 
> 	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=init_task
> 

I pulled this branch and it builds on all of my ia64 test
configurations. Boots too.

So no ia64 breakage.

-Tony
