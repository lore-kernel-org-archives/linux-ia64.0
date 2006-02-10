From: Andi Kleen <ak@suse.de>
Date: Fri, 10 Feb 2006 17:15:12 +0000
Subject: Re: [discuss] [RFC/PATCH: 004/010] Memory hotplug for new nodes with pgdat allocation. (pgdat alloc
Message-Id: <200602101815.12914.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060210224257.C536.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060210224257.C536.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: discuss@x86-64.org
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, "Luck, Tony" <tony.luck@intel.com>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>

On Friday 10 February 2006 15:21, Yasunori Goto wrote:
> This is sample code of calling pgdat allocation function for x86_64.
> Basically it is same with ia64. 
> 
> I've not tried this patch yet, due to I couldn't make emulation for
> new node addtion for x86_64. This is just to reference. :-P

Looks ok basically assuming someone tests it

(I guess it would be possible to hack the numa emulation to support
hotplug) 

-Andi
