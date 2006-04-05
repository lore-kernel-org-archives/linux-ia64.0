From: Zou Nan hai <nanhai.zou@intel.com>
Date: Wed, 05 Apr 2006 02:05:06 +0000
Subject: Re: 2.6.17-rc1-mm1
Message-Id: <1144202706.3197.11.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060404014504.564bf45a.akpm@osdl.org>
	 <20060404233851.GA6411@agluck-lia64.sc.intel.com>
In-Reply-To: <20060404233851.GA6411@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, 2006-04-05 at 07:38, Luck, Tony wrote:
> On Tue, Apr 04, 2006 at 01:45:04AM -0700, Andrew Morton wrote:
> > - VGA on ia64 is broken - the screen comes up blank.  But ia64 otherwise
> >   seems to work OK.  I didn't have time to investigate.
> 
> Broken in base 2.6.17-rc1 too :-(  VGA comes up and prints a
> few messages, and then goes wonky and dies.  Comparing
> what I _think_ I saw with the dmesg output, it appears to
> die here:
> 

The wild VGA comes from the patch which changed ioremap.

Now ioremap would not remap memory to region 6 unless that memory is
marked as EFI_MEMORY_UC by EFI.

Unfortunately on the Tiger Machine, VGA ram base was marked as
EFI_MEMORY_WB instead of EFI_MEMORY_UC...

So you can see the problem disappear if change VGA_MAP_MEM to use
ioremap_nocache.

But I am not quite sure if we can fully trust EFI on this attribute.

Zou Nan hai
