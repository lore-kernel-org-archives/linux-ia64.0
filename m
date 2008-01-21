From: "Xu, Anthony" <anthony.xu@intel.com>
Date: Mon, 21 Jan 2008 03:31:32 +0000
Subject: RE: [PATCH]Add TR insert/purge interface for add-on component
Message-Id: <51CFAB8CB6883745AE7B93B3E084EBE20167042C@pdsmsx412.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <51CFAB8CB6883745AE7B93B3E084EBE201670418@pdsmsx412.ccr.corp.intel.com> <20080121032535.GE27250@parisc-linux.org>
In-Reply-To: <20080121032535.GE27250@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, kvm-devel <kvm-devel@lists.sourceforge.net>

Matthew Wilcox wrote:
> On Mon, Jan 21, 2008 at 11:18:03AM +0800, Xu, Anthony wrote:
>> Hi Avi/Tony,
>> 	This patch adds the TR insert/purge interface for add-on
>> components.
> 
> In my world, TR stands for Token Ring.  Nowhere in this patch do you
> explain what TR means to you!


Sorry for confusing word.
TR stands for TLB register.
In Ia64 platform there are two kinds of TLBs,
One is TLB caches, briefly TC, which can be gone at anytime.
The other is TLB registers, briefly TR, which will not be gone until
software purges it explicitly.


- Anthony
