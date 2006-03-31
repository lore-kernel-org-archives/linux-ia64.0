From: Andrew Morton <akpm@osdl.org>
Date: Fri, 31 Mar 2006 18:20:53 +0000
Subject: Re: [patch] avoid unaligned access when accessing poll stack
Message-Id: <20060331102053.2a440f81.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0sloytyj5.fsf@jaguar.mkp.net>
In-Reply-To: <yq0sloytyj5.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: torvalds@osdl.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Jes Sorensen <jes@sgi.com> wrote:
>
>   [PATCH] Optimize select/poll by putting small data sets on the stack
>  resulted in the poll stack being 4-byte aligned on 64-bit
>  architectures, causing misaligned accesses to elements in the array.

How come you noticed this but I did not?
