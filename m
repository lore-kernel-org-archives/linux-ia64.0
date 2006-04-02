From: Jes Sorensen <jes@sgi.com>
Date: Sun, 02 Apr 2006 14:49:35 +0000
Subject: Re: [patch] avoid unaligned access when accessing poll stack
Message-Id: <442FE47F.9040008@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0sloytyj5.fsf@jaguar.mkp.net> <20060331102053.2a440f81.akpm@osdl.org>
In-Reply-To: <20060331102053.2a440f81.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: torvalds@osdl.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Andrew Morton wrote:
> Jes Sorensen <jes@sgi.com> wrote:
>>   [PATCH] Optimize select/poll by putting small data sets on the stack
>>  resulted in the poll stack being 4-byte aligned on 64-bit
>>  architectures, causing misaligned accesses to elements in the array.
> 
> How come you noticed this but I did not?

Heh,

The ia64 kernel spits out nifty little messages moaning about this since
it goes to firmware emulation. They were all in the middle of the bootup
messages making them a bit harder to notice as well.

Cheers,
Jes
