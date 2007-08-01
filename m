From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 01 Aug 2007 20:02:39 +0000
Subject: Re: ACPI: Uninitialized spinlocks & Unable to dump stack
Message-Id: <Pine.LNX.4.64.0708011301090.28485@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0707312246390.14878@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707312246390.14878@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 1 Aug 2007, Russ Anderson wrote:

> The bad news is the kernel boot on SN2 still hangs in udevsettle.

We found two problems with clocks that account for the udevsettle hang.

Kenji's patch is still necessary to get rid of the spinlock problems.


