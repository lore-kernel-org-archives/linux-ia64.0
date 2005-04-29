From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 29 Apr 2005 15:20:25 +0000
Subject: Re: write_unlock: replace clear_bit with byte store
Message-Id: <Pine.LNX.4.58.0504290819320.30446@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 29 Apr 2005, David Mosberger wrote:

>   Christoph> y is defined in its own block.
>
> Ummh, macros 101: think about what happens for _raw_write_unlock(y)...

Not if its defined in an inline function.

