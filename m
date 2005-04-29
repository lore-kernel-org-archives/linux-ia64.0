From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 29 Apr 2005 15:19:20 +0000
Subject: Re: write_unlock: replace clear_bit with byte store
Message-Id: <Pine.LNX.4.58.0504290814350.30446@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 29 Apr 2005, David Mosberger wrote:

> Let's not reintroduce in-line asm, please?

How do I do a nta store without inline asm? There is already lots of
inline asm in spinlock.h.
